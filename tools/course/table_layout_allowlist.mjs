/**
 * Table-layout allowlist (content/course/v2/table_layout_allowlist.json).
 *
 * Every lesson step draws the full six-max poker table in the lesson frame —
 * choice / number drills included (answers in the action-button row). The
 * Flutter contract test (test/ui/course/lesson_table_layout_contract_test.dart)
 * pumps every catalog step and fails when one renders without the table and
 * is not listed here. This module keeps the list honest from course:check:
 * every entry must name a real activity id and give a reason.
 */
import {readFileSync} from "node:fs";

/** @param {string} path */
export function loadTableLayoutAllowlist(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

/**
 * @param {any} course course.json source
 * @param {any} allowlist parsed allowlist file
 * @returns {string[]} problems
 */
export function tableLayoutAllowlistProblems(course, allowlist) {
  const problems = [];
  if (!allowlist || typeof allowlist !== "object" || Array.isArray(allowlist)) {
    return ["table layout allowlist: must be an object"];
  }
  const allow = allowlist.allow;
  if (!allow || typeof allow !== "object" || Array.isArray(allow)) {
    return ['table layout allowlist: "allow" must be an object of id → reason'];
  }
  const ids = new Set();
  for (const section of course?.sections ?? []) {
    for (const unit of section?.units ?? []) {
      for (const lesson of unit?.lessons ?? []) {
        for (const act of lesson?.activities ?? []) {
          if (typeof act?.id === "string") ids.add(act.id);
        }
      }
    }
  }
  for (const [id, reason] of Object.entries(allow)) {
    if (!ids.has(id)) {
      problems.push(`table layout allowlist: unknown activity id "${id}"`);
    }
    if (typeof reason !== "string" || reason.trim().length < 12) {
      problems.push(
        `table layout allowlist: "${id}" needs a reason why it cannot sit on the table`,
      );
    }
  }
  return problems;
}
