// Guards the lesson-content-agent learnings file against unbounded growth
// (it reached 641 bullets / 2,800 lines in Oct 2026). Cap is 40 bullets.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const file = join(root, '.cursor/commands/lesson-content-agent-learnings.md');

test('lesson-content-agent learnings stay within the 40-bullet cap', () => {
  const text = readFileSync(file, 'utf8');
  const bullets = text.split('\n').filter((l) => l.startsWith('- '));
  assert.ok(bullets.length <= 40, `${bullets.length} bullets > 40 cap — trim ${file}`);
  assert.ok(!/^## Recent fold/m.test(text), 'dated fold logs belong in git history, not the learnings file');
});
