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

function createArtifactDir(
  targetPath: string,
  cwd: string,
): { success: boolean; resolvedPath: string; error?: string } {
  try {
    const resolvedPath = path.isAbsolute(targetPath)
      ? targetPath
      : path.resolve(cwd, targetPath);

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
