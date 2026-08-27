import * as fs from "node:fs";
import * as path from "node:path";
import type {
  AgentToolResult,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

export type CreateArtifactDirectoryResult = AgentToolResult<{path: string, status: "created"}|{error: string|undefined, status: "failed" }>;

export async function createArtifactDirectory(
  path: string,
  ctx: ExtensionContext,
): Promise<CreateArtifactDirectoryResult> {
  const result = createArtifactDir(path, ctx.cwd);
  if (result.success) {
    return {
      content: [
        {
          type: "text",
          text: `Artifact directory created: ${path}`,
        },
      ],
      details: { path: result.resolvedPath, status: "created" },
    };
  } else {
    return {
      content: [
        {
          type: "text",
          text: `Failed to create artifact directory "${path}": ${result.error}`,
        },
      ],
      details: { error: result.error, status: "failed" },
    };
  }
}

const ARTIFACT_ROOT_SEGMENTS = [".agents", "thoughts", "rpi"];

function createArtifactDir(
  targetPath: string,
  cwd: string,
): { success: boolean; resolvedPath: string; error?: string } {
  try {
    const resolvedPath = path.isAbsolute(targetPath)
      ? targetPath
      : path.resolve(cwd, targetPath);

    // Guard: the directory must be a strict subdirectory of
    // <cwd>/.agents/thoughts/rpi/ — arbitrary paths (e.g. relative paths
    // outside the artifact root) are rejected.
    const artifactRoot = path.resolve(cwd, ...ARTIFACT_ROOT_SEGMENTS);
    const rel = path.relative(artifactRoot, resolvedPath);
    if (rel === "" || rel.startsWith("..") || path.isAbsolute(rel)) {
      return {
        success: false,
        resolvedPath,
        error: `"${targetPath}" is not a subdirectory of ${path.join(...ARTIFACT_ROOT_SEGMENTS)}/`,
      };
    }

    fs.mkdirSync(resolvedPath, { recursive: true });
    return { success: true, resolvedPath };
  } catch (err) {
    const errMsg = err instanceof Error ? err.message : String(err);
    return {
      success: false,
      resolvedPath: path.isAbsolute(targetPath)
        ? targetPath
        : path.resolve(cwd, targetPath),
      error: errMsg,
    };
  }
}

export type ArtifactResult = AgentToolResult<
  | { path: string; action: string; status: "success" }
  | { error: string | undefined; status: "failed" }
>;

export interface ManageArtifactParams {
  action: "create" | "modify" | "delete";
  /** Artifact session directory, e.g. .agents/thoughts/rpi/2026-07-12-brief-description */
  dir: string;
  /** Artifact file path, relative to dir */
  path: string;
  /** Full file content (required for create/modify) */
  content?: string;
}

/** Resolve `target` against `base` and return the resolved path, or null if it escapes `base`. */
function resolveInside(base: string, target: string): string | null {
  const resolved = path.isAbsolute(target)
    ? target
    : path.resolve(base, target);
  const rel = path.relative(path.resolve(base), resolved);
  if (rel === "" || rel.startsWith("..") || path.isAbsolute(rel)) {
    return null;
  }
  return resolved;
}

/**
 * Resolve `target` against `base` (without requiring it to be inside) and check
 * that the result is a strict subpath of `root`.
 */
function resolveUnderRoot(
  base: string,
  target: string,
  root: string,
): string | null {
  const resolved = path.isAbsolute(target)
    ? target
    : path.resolve(base, target);
  const rel = path.relative(path.resolve(root), resolved);
  if (rel === "" || rel.startsWith("..") || path.isAbsolute(rel)) {
    return null;
  }
  return resolved;
}

export async function manageArtifact(
  params: ManageArtifactParams,
  ctx: ExtensionContext,
): Promise<ArtifactResult> {
  const fail = (error: string): ArtifactResult => ({
    content: [
      {
        type: "text",
        text: `Failed to ${params.action} artifact "${params.path}" in "${params.dir}": ${error}`,
      },
    ],
    details: { error, status: "failed" },
  });

  try {
    // Guard 1: dir must be a strict subdirectory of <cwd>/.agents/thoughts/rpi/
    const artifactRoot = path.resolve(ctx.cwd, ...ARTIFACT_ROOT_SEGMENTS);
    const dir = resolveUnderRoot(ctx.cwd, params.dir, artifactRoot);
    if (!dir) {
      return fail(
        `"${params.dir}" is not a subdirectory of ${path.join(...ARTIFACT_ROOT_SEGMENTS)}/`,
      );
    }

    // Guard 2: file path must stay inside dir
    const filePath = resolveInside(dir, params.path);
    if (!filePath) {
      return fail(`"${params.path}" escapes the artifact directory "${params.dir}"`);
    }

    switch (params.action) {
      case "create": {
        if (params.content === undefined) {
          return fail('content is required for action "create"');
        }
        if (fs.existsSync(filePath)) {
          return fail('file already exists — use action "modify" to overwrite it');
        }
        fs.mkdirSync(path.dirname(filePath), { recursive: true });
        fs.writeFileSync(filePath, params.content, "utf8");
        break;
      }
      case "modify": {
        if (params.content === undefined) {
          return fail('content is required for action "modify"');
        }
        if (!fs.existsSync(filePath)) {
          return fail("file does not exist");
        }
        fs.writeFileSync(filePath, params.content, "utf8");
        break;
      }
      case "delete": {
        if (!fs.existsSync(filePath)) {
          return fail("file does not exist");
        }
        if (fs.statSync(filePath).isDirectory()) {
          return fail("deleting directories is not allowed — files only");
        }
        fs.rmSync(filePath);
        break;
      }
      default:
        return fail(`unknown action "${String(params.action)}"`);
    }

    return {
      content: [
        {
          type: "text",
          text: `Artifact ${params.action === "create" ? "created" : params.action === "modify" ? "modified" : "deleted"}: ${filePath}`,
        },
      ],
      details: { path: filePath, action: params.action, status: "success" },
    };
  } catch (err) {
    const errMsg = err instanceof Error ? err.message : String(err);
    return fail(errMsg);
  }
}
