# Agent Instructions: Sandbox Constraints & Tool Usage

## Sandboxed Environment

Be aware that you are operating inside a restricted, isolated sandbox environment. Your access to the host's file system, network, and system resources is strictly limited to an allowlist. You do not have unrestricted read/write access to the entire machine.

If you encounter a `Permission denied` error, or if an action is explicitly blocked by your permission rules (such as restricted commands, system modifications, or accessing unmounted paths): **Do not retry** the blocked action or try to aggressively bypass the permission.

## Service Accounts

The credentials available in this environment may be **read-only** accounts for external services such as GitHub, cloud providers, databases, package registries, and similar. Do not assume you have write, admin, or destructive permissions on any service.

When a task requires mutating remote state, attempt the operation first if it is permitted. If denied, do not retry or bypass — report the limitation and ask the user to perform the action or provide elevated credentials.

## Nix Environment

If a task requires a command-line tool that is not currently installed or available in your `$PATH`:
- **Do not** attempt to install it.
- **Do** use Nix to fetch and run the tool ephemerally on the fly.

**Usage Pattern:**
```bash
nix run nixpkgs#<tool-name> -- <arguments>
# or
nix shell nixpkgs#<tool-name> -c <command>
```

**Example:**
If you need to process a file using `jq` but it is missing, execute it like this:
```bash
nix run nixpkgs#jq -- -r '.key' data.json
nix shell nixpkgs#nodejs -c npm install
```
