#!/usr/bin/env node
/**
 * Launch one local Cursor SDK agent run for the ui-design-agent loop.
 *
 * Local runtime keeps iPhone 13 mini / sim_lock access on this Mac while
 * registering the chat under the Agents UI "SDK" source (unlike `agent -p`).
 *
 * Usage:
 *   node run.mjs --cwd <repo> --model <id> --log <path> --meta <path> -- <prompt>
 *
 * Exit codes: 0 ok, 1 startup/run error, 2 run status error, 14 usage limit.
 */

import { createWriteStream } from "node:fs";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { Agent, CursorAgentError } from "@cursor/sdk";

function usage() {
  console.error(
    "usage: node run.mjs --cwd <repo> [--model default] --log <path> [--meta <path>] -- <prompt>",
  );
  process.exit(1);
}

function parseArgs(argv) {
  const out = {
    cwd: "",
    model: "default",
    log: "",
    meta: "",
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
    else usage();
  }
  if (!out.cwd || !out.log || !out.prompt) usage();
  // CLI "auto" and empty → SDK catalog id "default" (Agents UI Auto).
  if (!out.model || out.model === "auto") out.model = "default";
  return out;
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

  log(`# ui-agent-sdk start model=${opts.model} cwd=${opts.cwd}`);

  let agent;
  try {
    agent = await Agent.create({
      apiKey,
      model: { id: opts.model },
      local: {
        cwd: opts.cwd,
        // Headless unattended loop: no approval prompts (same as agent -p --force).
        sandboxOptions: { enabled: false },
      },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    log(`# ui-agent-sdk create failed: ${message}`);
    if (/usage limit|resource_exhausted|ActionRequiredError/i.test(message)) {
      process.exit(14);
    }
    process.exit(1);
  }

  const agentId = agent.agentId || "";
  log(`# ui-agent-sdk agentId=${agentId}`);
  if (opts.meta) {
    mkdirSync(dirname(opts.meta), { recursive: true });
    writeFileSync(
      opts.meta,
      `${JSON.stringify({
        at: new Date().toISOString(),
        agentId,
        model: opts.model,
        cwd: opts.cwd,
        source: "sdk-local",
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
