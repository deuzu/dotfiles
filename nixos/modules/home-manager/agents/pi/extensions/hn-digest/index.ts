/**
 * /hn [count] — Hacker News digest.
 *
 * Fetches the top posts from the HN front page (via the Algolia API),
 * grabs the top comments for each, then hands the data to the agent to
 * summarize in chat. Registers only a slash command: zero footprint in
 * the LLM context until invoked.
 *
 * Usage:
 *   /hn        — top 30 posts
 *   /hn 10     — top 10 posts
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const ALGOLIA = "https://hn.algolia.com/api/v1";
const DEFAULT_COUNT = 30;
const MAX_COUNT = 50;
const COMMENTS_PER_POST = 5;
const COMMENT_EXCERPT_LEN = 1000;
const FETCH_TIMEOUT_MS = 15_000;

interface StoryHit {
  objectID: string;
  title: string;
  url: string | null;
  points: number | null;
  author: string | null;
  num_comments: number | null;
}

interface ItemNode {
  text?: string | null;
  children?: ItemNode[];
}

async function fetchJSON<T>(url: string): Promise<T> {
  const res = await fetch(url, { signal: AbortSignal.timeout(FETCH_TIMEOUT_MS) });
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  return (await res.json()) as T;
}

/** Decode HTML entities and strip tags from HN comment text. */
function stripHtml(html: string): string {
  return html
    .replace(/<p>/gi, "\n")
    .replace(/<[^>]+>/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#x27;|&#39;/g, "'")
    .replace(/&#x2F;/g, "/")
    .replace(/&nbsp;/g, " ")
    .replace(/[ \t]+/g, " ")
    .replace(/\s*\n\s*/g, "\n")
    .trim();
}

async function fetchTopComments(storyId: string): Promise<string[]> {
  try {
    const item = await fetchJSON<ItemNode>(`${ALGOLIA}/items/${storyId}`);
    const excerpts: string[] = [];
    for (const child of item.children ?? []) {
      if (!child.text) continue;
      const text = stripHtml(child.text);
      if (text.length < 20) continue; // skip "source?", dead links, etc.
      excerpts.push(
        text.length > COMMENT_EXCERPT_LEN
          ? text.slice(0, COMMENT_EXCERPT_LEN).trimEnd() + "…"
          : text
      );
      if (excerpts.length >= COMMENTS_PER_POST) break;
    }
    return excerpts;
  } catch {
    return [];
  }
}

function buildPayload(hits: StoryHit[], comments: Map<string, string[]>): string {
  const lines: string[] = [];
  hits.forEach((hit, i) => {
    const discussion = `https://news.ycombinator.com/item?id=${hit.objectID}`;
    lines.push(`### ${i + 1}. ${hit.title}`);
    lines.push(`- HN URL: ${discussion}`);
    lines.push(`- Post URL: ${hit.url}`);
    lines.push(
      `- ${hit.points ?? "?"} points, ${hit.num_comments ?? 0} comments, by ${hit.author ?? "unknown"}`
    );
    const excerpts = comments.get(hit.objectID) ?? [];
    if (excerpts.length > 0) {
      lines.push("- Top comments:");
      excerpts.forEach((c, j) => lines.push(`  ${j + 1}. ${c.replace(/\n/g, " ")}`));
    }
    lines.push("- Comments summary: <replace_with_comment_summary>");
    lines.push("");
  });

  return [
    `Below are the top ${hits.length} Hacker News posts, fetched just now.`,
    ``,
    `Write a digest of these posts. For each post, numbered in the same order:`,
    `For each post, keep the same format and add a summary of the comments by replacing the variable \`<replace_with_comment_summary>\`. Keep raw comments untouched.`,
    ``,
    `--- DATA ---`,
    ``,
    lines.join("\n"),
  ].join("\n");
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("hn", {
    description: "Summarize the top Hacker News posts (with top comments)",
    getArgumentCompletions: (prefix: string) => {
      const items = [10, 20, 30, 50].map((n) => ({
        value: String(n),
        label: `top ${n} posts`,
      }));
      const filtered = items.filter((i) => i.value.startsWith(prefix));
      return filtered.length > 0 ? filtered : null;
    },
    handler: async (args: string, ctx) => {
      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy — run /hn again once the current turn finishes.", "warning");
        return;
      }

      const requested = parseInt(args.trim(), 10);
      const count = Math.min(
        Number.isFinite(requested) && requested > 0 ? requested : DEFAULT_COUNT,
        MAX_COUNT
      );

      ctx.ui.notify(`Fetching top ${count} Hacker News posts…`, "info");

      try {
        // Front page first; top it up from popular stories if it runs short.
        let hits: StoryHit[] = (
          await fetchJSON<{ hits: StoryHit[] }>(
            `${ALGOLIA}/search?tags=front_page&hitsPerPage=${count}`
          )
        ).hits.filter((h) => h.title);

        if (hits.length < count) {
          const more: StoryHit[] = (
            await fetchJSON<{ hits: StoryHit[] }>(
              `${ALGOLIA}/search?tags=story&hitsPerPage=${count}`
            )
          ).hits;
          const seen = new Set(hits.map((h) => h.objectID));
          for (const h of more) {
            if (hits.length >= count) break;
            if (h.title && !seen.has(h.objectID)) hits.push(h);
          }
        }
        hits = hits.slice(0, count);

        if (hits.length === 0) throw new Error("Hacker News returned no posts");

        // Fetch top comments in batches of 10 to be polite to the API.
        const comments = new Map<string, string[]>();
        for (let i = 0; i < hits.length; i += 10) {
          await Promise.all(
            hits.slice(i, i + 10).map(async (h) => {
              comments.set(h.objectID, await fetchTopComments(h.objectID));
            })
          );
        }

        ctx.ui.notify(`Fetched ${hits.length} posts — summarizing…`, "info");

        pi.sendMessage(
          {
            customType: "hn-digest-data",
            content: buildPayload(hits, comments),
            display: true, // data stays out of the TUI; only the summary is shown
          },
          { triggerTurn: true }
        );
      } catch (err) {
        ctx.ui.notify(
          `Failed to fetch Hacker News: ${err instanceof Error ? err.message : String(err)}`,
          "error"
        );
      }
    },
  });
}
