#!/usr/bin/env node
/**
 * Launch one Cursor SDK agent run for the ui-design-agent loop.
 *
 * Default runtime is cloud + My Machines worker on this Mac mini so the chat
 * appears in the Cursor Agents sidebar as a bc-* agent (same place as other
 * remote-machine chats). Pass --runtime local for an on-process local agent.
 *
 * Usage:
 *   node run.mjs --cwd <repo> --model <id> --log <path> --meta <path> \
 *     [--runtime machine|local] [--machine <worker-name>] [--repo <url>] \
 *     -- <prompt>
 *
 * Exit codes: 0 ok, 1 startup/run error, 2 run status error, 14 usage limit.
 */

import { createWriteStream } from "node:fs";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { execFileSync } from "node:child_process";
import { Agent, CursorAgentError } from "@cursor/sdk";

/** Default My Machines worker label for ~/live-poker-trainer on Kushal's Mac mini. */
const DEFAULT_MACHINE = "cursor-agent-worker-4c8b3dc416";
const DEFAULT_REPO = "https://github.com/kc38/live-poker-trainer";

function usage() {
  console.error(
    "usage: node run.mjs --cwd <repo> [--model default] --log <path> [--meta <path>] " +
      "[--runtime machine|local] [--machine <name>] [--repo <url>] -- <prompt>",
  );
  process.exit(1);
}

function parseArgs(argv) {
  const out = {
    cwd: "",
    model: "default",
    log: "",
    meta: "",
    runtime: process.env.UI_AGENT_SDK_RUNTIME || "machine",
    machine: process.env.UI_AGENT_MACHINE_NAME || DEFAULT_MACHINE,
    repo: process.env.UI_AGENT_REPO_URL || "",
    prompt: "",
  };
  const args = [...argv];
  while (args.length) {
    const arg = args.shift();
    if (arg === "--") {
      out.prompt = args.join(" ").trim();
      break;
    }
    if (arg === "--cwd") out.cwd = args.shift() || "";
    else if (arg === "--model") out.model = args.shift() || "default";
    else if (arg === "--log") out.log = args.shift() || "";
    else if (arg === "--meta") out.meta = args.shift() || "";
    else if (arg === "--runtime") out.runtime = args.shift() || "machine";
    else if (arg === "--machine") out.machine = args.shift() || DEFAULT_MACHINE;
    else if (arg === "--repo") out.repo = args.shift() || "";
    else usage();
  }
  if (!out.cwd || !out.log || !out.prompt) usage();
  if (!out.model || out.model === "auto") out.model = "default";
  if (out.runtime !== "machine" && out.runtime !== "local") {
    console.error(`unsupported runtime: ${out.runtime}`);
    process.exit(1);
  }
  return out;
}

function resolveRepoUrl(cwd, explicit) {
  if (explicit) return explicit;
  try {
    const url = execFileSync("git", ["-C", cwd, "remote", "get-url", "origin"], {
      encoding: "utf8",
    }).trim();
    if (url.startsWith("git@github.com:")) {
      return `https://github.com/${url.slice("git@github.com:".length).replace(/\.git$/, "")}`;
    }
    if (url.startsWith("https://github.com/")) {
      return url.replace(/\.git$/, "").replace("https://github.com/KC38/", "https://github.com/kc38/");
    }
    return url || DEFAULT_REPO;
  } catch {
    return DEFAULT_REPO;
  }
}

function cloudEnvVars() {
  const keys = [
    "SIM_LOCK_RUN_ID",
    "SIM_LOCK_PID",
    "ATLASSIAN_EMAIL",
    "ATLASSIAN_API_TOKEN",
    "FIREBASE_TOKEN",
  ];
  /** @type {Record<string, string>} */
  const envVars = {};
  for (const key of keys) {
    const value = process.env[key];
    if (value) envVars[key] = value;
  }
  return envVars;
}

function appendLine(stream, line) {
  stream.write(`${line}\n`);
}

function textFromEvent(event) {
  if (!event || typeof event !== "object") return "";
  if (event.type === "assistant" && event.message?.content) {
    return event.message.content
      .filter((block) => block?.type === "text" && block.text)
      .map((block) => block.text)
      .join("");
  }
  if (typeof event.text === "string") return event.text;
  return "";
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  const apiKey = (process.env.CURSOR_API_KEY || "").trim();
  if (!apiKey) {
    console.error("CURSOR_API_KEY is required");
    process.exit(1);
  }

  mkdirSync(dirname(opts.log), { recursive: true });
  const logStream = createWriteStream(opts.log, { flags: "a" });
  const log = (line) => {
    appendLine(logStream, line);
    process.stdout.write(`${line}\n`);
  };

  const repoUrl = resolveRepoUrl(opts.cwd, opts.repo);
  log(
    `# ui-agent-sdk start runtime=${opts.runtime} model=${opts.model}` +
      (opts.runtime === "machine" ? ` machine=${opts.machine} repo=${repoUrl}` : ` cwd=${opts.cwd}`),
  );

  /** @type {import("@cursor/sdk").AgentOptions} */
  const createOpts = {
    apiKey,
    model: { id: opts.model },
  };
  if (opts.runtime === "machine") {
    createOpts.cloud = {
      env: { type: "machine", name: opts.machine },
      repos: [{ url: repoUrl, startingRef: "main" }],
      envVars: cloudEnvVars(),
      skipReviewerRequest: true,
    };
  } else {
    createOpts.local = {
      cwd: opts.cwd,
      sandboxOptions: { enabled: false },
    };
  }

  let agent;
  try {
    agent = await Agent.create(createOpts);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    log(`# ui-agent-sdk create failed: ${message}`);
    if (/usage limit|resource_exhausted|ActionRequiredError/i.test(message)) {
      process.exit(14);
    }
    process.exit(1);
  }

  const agentId = agent.agentId || "";
  const agentUrl = agentId.startsWith("bc-")
    ? `https://cursor.com/agents/${agentId}`
    : "";
  log(`# ui-agent-sdk agentId=${agentId}${agentUrl ? ` url=${agentUrl}` : ""}`);
  if (opts.meta) {
    mkdirSync(dirname(opts.meta), { recursive: true });
    writeFileSync(
      opts.meta,
      `${JSON.stringify({
        at: new Date().toISOString(),
        agentId,
        agentUrl,
        model: opts.model,
        runtime: opts.runtime,
        machine: opts.runtime === "machine" ? opts.machine : null,
        repo: opts.runtime === "machine" ? repoUrl : null,
        cwd: opts.cwd,
        source: opts.runtime === "machine" ? "sdk-machine" : "sdk-local",
      })}\n`,
      "utf8",
    );
  }

  try {
    const run = await agent.send(opts.prompt);
    log(`# ui-agent-sdk runId=${run.id || ""}`);
    try {
      for await (const event of run.stream()) {
        const text = textFromEvent(event);
        if (text) process.stdout.write(text);
        if (event?.type) {
          appendLine(logStream, JSON.stringify({ t: Date.now(), type: event.type }));
        }
      }
    } catch (streamErr) {
      const message =
        streamErr instanceof Error ? streamErr.message : String(streamErr);
      log(`# ui-agent-sdk stream error: ${message}`);
    }

    const result = await run.wait();
    log(`# ui-agent-sdk status=${result.status} resultId=${result.id || ""}`);
    if (result.result) {
      log(String(result.result).slice(0, 4000));
    }

    const blob = `${result.status || ""} ${result.result || ""}`;
    if (/usage limit|resource_exhausted|ActionRequiredError/i.test(blob)) {
      process.exit(14);
    }
    if (result.status === "error") {
      process.exit(2);
    }
    process.exit(0);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    log(`# ui-agent-sdk run failed: ${message}`);
    if (err instanceof CursorAgentError) {
      log(`# ui-agent-sdk retryable=${Boolean(err.isRetryable)}`);
    }
    if (/usage limit|resource_exhausted|ActionRequiredError/i.test(message)) {
      process.exit(14);
    }
    process.exit(1);
  } finally {
    try {
      if (agent && typeof agent[Symbol.asyncDispose] === "function") {
        await agent[Symbol.asyncDispose]();
      } else if (agent?.close) {
        await agent.close();
      }
    } catch {
      // ignore dispose errors
    }
    logStream.end();
  }
}

main();
