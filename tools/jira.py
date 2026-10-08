#!/usr/bin/env python3
"""Small Jira Cloud client for the LPT project, over the REST API.

Agents (``/ui-design-agent``) use this instead of the Atlassian MCP server so
an unattended run needs only a scoped API token: no browser, no keychain.

Credentials come from ``$ATLASSIAN_EMAIL`` and ``$ATLASSIAN_API_TOKEN``, or
from ``~/.live-poker-trainer/secrets.env`` when those are unset. Requests go
through the API gateway (``https://api.atlassian.com/ex/jira/<cloudId>``),
which scoped tokens require. The token needs ``read:jira-work``,
``write:jira-work``, and ``read:jira-user``.

Bodies are written in Markdown and converted to Jira wiki markup. An image
written as ``![what it shows](file.png)`` renders the attachment ``file.png``.

Commands:

    check                           confirm read and write access to LPT
    search JQL [--max N]            one line per issue
    get KEY                         summary, fields, description, comments, links
    create --type T --summary S --body-file F [--priority P] [--labels a,b]
           [--attach FILE ...]      prints the new key
    edit KEY [--summary S] [--body-file F] [--priority P]
             [--add-label L ...] [--remove-label L ...]
    comment KEY --body-file F [--attach FILE ...]
    attach KEY FILE ...
    transitions KEY                 id, name, and target status
    transition KEY --to STATUS      move by target status or transition name
    link --type Blocks --inward A --outward B   (A blocks B)
"""

from __future__ import annotations

import argparse
import base64
import json
import mimetypes
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional

CLOUD_ID = os.environ.get("JIRA_CLOUD_ID", "6c3dffc6-003e-49f8-a8fb-0acc800ca7e7")
SITE = "https://livepokertrainer.atlassian.net"
PROJECT = "LPT"
SECRETS_FILE = Path.home() / ".live-poker-trainer" / "secrets.env"

Json = Dict[str, Any]


class JiraError(RuntimeError):
    """A Jira request failed."""


def _secrets() -> Dict[str, str]:
    """Read KEY=value lines from the secrets file (shell-quoted values allowed)."""
    values: Dict[str, str] = {}
    try:
        lines = SECRETS_FILE.read_text(encoding="utf-8").splitlines()
    except OSError:
        return values
    for line in lines:
        if "=" not in line or line.lstrip().startswith("#"):
            continue
        key, raw = line.split("=", 1)
        values[key.strip()] = _unquote(raw.strip())
    return values


def _unquote(raw: str) -> str:
    """Undo the quoting bash's ``printf %q`` and simple quotes produce."""
    if len(raw) >= 2 and raw[0] == raw[-1] and raw[0] in "'\"":
        return raw[1:-1]
    if raw.startswith("$'") and raw.endswith("'"):
        return raw[2:-1].encode("utf-8").decode("unicode_escape")
    return re.sub(r"\\(.)", r"\1", raw)


def credentials() -> tuple[str, str]:
    """Return (email, token) from the environment or the secrets file."""
    saved = _secrets()
    email = os.environ.get("ATLASSIAN_EMAIL") or saved.get("ATLASSIAN_EMAIL", "")
    token = os.environ.get("ATLASSIAN_API_TOKEN") or saved.get("ATLASSIAN_API_TOKEN", "")
    if not email or not token:
        raise JiraError(
            "No Atlassian credentials. Run tools/ui_design_agent_loop.sh setup "
            f"or set ATLASSIAN_EMAIL and ATLASSIAN_API_TOKEN ({SECRETS_FILE})."
        )
    return email, token


def _base() -> str:
    """REST root through the API gateway."""
    return f"https://api.atlassian.com/ex/jira/{CLOUD_ID}/rest/api"


def request(
    method: str,
    path: str,
    body: Optional[Any] = None,
    query: Optional[Dict[str, Any]] = None,
    raw: Optional[bytes] = None,
    headers: Optional[Dict[str, str]] = None,
) -> Any:
    """Send one request; return parsed JSON (or None for an empty reply)."""
    email, token = credentials()
    url = _base() + path
    if query:
        url += "?" + urllib.parse.urlencode(query, doseq=True)
    auth = base64.b64encode(f"{email}:{token}".encode()).decode()
    all_headers = {"Authorization": f"Basic {auth}", "Accept": "application/json"}
    data = raw
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        all_headers["Content-Type"] = "application/json"
    all_headers.update(headers or {})
    req = urllib.request.Request(url, data=data, method=method, headers=all_headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            payload = resp.read()
    except urllib.error.HTTPError as err:
        detail = err.read().decode("utf-8", "replace")[:800]
        raise JiraError(f"{method} {path} -> HTTP {err.code}: {detail}") from err
    except urllib.error.URLError as err:
        raise JiraError(f"{method} {path} failed: {err.reason}") from err
    if not payload:
        return None
    return json.loads(payload.decode("utf-8"))


# Markdown to Jira wiki markup -------------------------------------------------

_INLINE_CODE = re.compile(r"`([^`]+)`")
_IMAGE = re.compile(r"!\[[^\]]*\]\(([^)\s]+)\)")
_LINK = re.compile(r"\[([^\]]+)\]\(([^)\s]+)\)")
_BOLD = re.compile(r"\*\*(.+?)\*\*")
_TABLE_SEP = re.compile(r"^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$")


def _inline(text: str) -> str:
    """Convert inline Markdown in one line, leaving code spans untouched."""
    parts = _INLINE_CODE.split(text)
    out: List[str] = []
    for index, part in enumerate(parts):
        if index % 2:
            out.append("{{" + part + "}}")
            continue
        part = _IMAGE.sub(lambda m: f"!{Path(m.group(1)).name}|thumbnail!", part)
        part = _LINK.sub(lambda m: f"[{m.group(1)}|{m.group(2)}]", part)
        part = _BOLD.sub(r"*\1*", part)
        out.append(part)
    return "".join(out)


def md_to_wiki(markdown: str) -> str:
    """Convert the Markdown agents write (headings, lists, code, tables) to wiki markup."""
    lines = markdown.splitlines()
    out: List[str] = []
    in_code = False
    index = 0
    while index < len(lines):
        line = lines[index]
        fence = re.match(r"^\s*```(\w*)\s*$", line)
        if fence:
            if in_code:
                out.append("{code}")
            else:
                lang = fence.group(1)
                out.append("{code:" + lang + "}" if lang else "{code}")
            in_code = not in_code
            index += 1
            continue
        if in_code:
            out.append(line)
            index += 1
            continue
        heading = re.match(r"^(#{1,6})\s+(.*)$", line)
        bullet = re.match(r"^(\s*)[-*]\s+(.*)$", line)
        numbered = re.match(r"^(\s*)\d+[.)]\s+(.*)$", line)
        if heading:
            out.append(f"h{len(heading.group(1))}. {_inline(heading.group(2))}")
        elif bullet:
            depth = len(bullet.group(1).replace("\t", "  ")) // 2 + 1
            out.append("*" * depth + " " + _inline(bullet.group(2)))
        elif numbered:
            depth = len(numbered.group(1).replace("\t", "  ")) // 2 + 1
            out.append("#" * depth + " " + _inline(numbered.group(2)))
        elif line.strip().startswith("|"):
            is_header = index + 1 < len(lines) and _TABLE_SEP.match(lines[index + 1])
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            joiner = "||" if is_header else "|"
            out.append(joiner + joiner.join(_inline(c) for c in cells) + joiner)
            if is_header:
                index += 1
        else:
            out.append(_inline(line))
        index += 1
    if in_code:
        out.append("{code}")
    return "\n".join(out)


# Operations -------------------------------------------------------------------

def search(jql: str, limit: int = 50) -> List[Json]:
    """Issues matching ``jql`` (key, type, status, priority, labels, summary)."""
    issues: List[Json] = []
    token: Optional[str] = None
    while len(issues) < limit:
        query: Dict[str, Any] = {
            "jql": jql,
            "maxResults": min(100, limit - len(issues)),
            "fields": "summary,status,priority,labels,issuetype",
        }
        if token:
            query["nextPageToken"] = token
        page = request("GET", "/3/search/jql", query=query) or {}
        issues.extend(page.get("issues", []))
        token = page.get("nextPageToken")
        if page.get("isLast", True) or not token:
            break
    return issues


def _issue_line(issue: Json) -> str:
    """One readable line for an issue."""
    fields = issue["fields"]
    labels = ",".join(fields.get("labels") or []) or "-"
    priority = (fields.get("priority") or {}).get("name", "-")
    return (
        f"{issue['key']}\t{fields['issuetype']['name']}\t{fields['status']['name']}\t"
        f"{priority}\t{labels}\t{fields['summary']}"
    )


def get(key: str) -> Json:
    """Full issue with wiki-text description and comments (REST v2)."""
    return request(
        "GET",
        f"/2/issue/{key}",
        query={"fields": "summary,status,priority,labels,issuetype,description,comment,issuelinks,attachment"},
    )


def format_issue(issue: Json) -> str:
    """Readable dump of ``get``'s result."""
    fields = issue["fields"]
    lines = [
        f"{issue['key']}: {fields['summary']}",
        f"Type: {fields['issuetype']['name']}  Status: {fields['status']['name']}  "
        f"Priority: {(fields.get('priority') or {}).get('name', '-')}",
        f"Labels: {', '.join(fields.get('labels') or []) or '-'}",
        f"URL: {SITE}/browse/{issue['key']}",
    ]
    for link in fields.get("issuelinks") or []:
        kind = link["type"]
        if "outwardIssue" in link:
            lines.append(f"Link: {kind['outward']} {link['outwardIssue']['key']}")
        if "inwardIssue" in link:
            lines.append(f"Link: {kind['inward']} {link['inwardIssue']['key']}")
    for item in fields.get("attachment") or []:
        lines.append(f"Attachment: {item['filename']}")
    lines += ["", "Description:", fields.get("description") or "(none)"]
    for comment in (fields.get("comment") or {}).get("comments", []):
        author = comment.get("author", {}).get("displayName", "?")
        lines += ["", f"Comment by {author} at {comment.get('created')}:", comment.get("body", "")]
    return "\n".join(lines)


def attach(key: str, paths: List[str]) -> List[str]:
    """Upload files to ``key``. Returns the stored file names."""
    names: List[str] = []
    for raw_path in paths:
        path = Path(raw_path)
        boundary = uuid.uuid4().hex
        mime = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
        body = (
            f"--{boundary}\r\nContent-Disposition: form-data; name=\"file\"; "
            f"filename=\"{path.name}\"\r\nContent-Type: {mime}\r\n\r\n"
        ).encode() + path.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
        result = request(
            "POST",
            f"/3/issue/{key}/attachments",
            raw=body,
            headers={
                "Content-Type": f"multipart/form-data; boundary={boundary}",
                "X-Atlassian-Token": "no-check",
            },
        )
        names.extend(item["filename"] for item in result or [])
    return names


def _embed_missing(wiki: str, names: List[str]) -> str:
    """Append thumbnails for attached files the body does not already show."""
    missing = [name for name in names if f"!{name}" not in wiki]
    if not missing:
        return wiki
    return wiki + "\n\n" + "\n".join(f"!{name}|thumbnail!" for name in missing)


def create(
    issue_type: str,
    summary: str,
    body: str,
    priority: Optional[str] = None,
    labels: Optional[List[str]] = None,
    files: Optional[List[str]] = None,
) -> str:
    """Create an LPT issue from Markdown; attach files and show them. Returns the key."""
    fields: Json = {
        "project": {"key": PROJECT},
        "issuetype": {"name": issue_type},
        "summary": summary,
        "description": md_to_wiki(body),
    }
    if priority:
        fields["priority"] = {"name": priority}
    if labels:
        fields["labels"] = labels
    key = request("POST", "/2/issue", body={"fields": fields})["key"]
    if files:
        names = attach(key, files)
        request(
            "PUT",
            f"/2/issue/{key}",
            body={"fields": {"description": _embed_missing(fields["description"], names)}},
        )
    return key


def edit(
    key: str,
    summary: Optional[str] = None,
    body: Optional[str] = None,
    priority: Optional[str] = None,
    add_labels: Optional[List[str]] = None,
    remove_labels: Optional[List[str]] = None,
) -> None:
    """Change fields on ``key``. Labels are added or removed, not replaced."""
    fields: Json = {}
    update: Json = {}
    if summary:
        fields["summary"] = summary
    if body is not None:
        fields["description"] = md_to_wiki(body)
    if priority:
        fields["priority"] = {"name": priority}
    label_ops = [{"add": label} for label in add_labels or []]
    label_ops += [{"remove": label} for label in remove_labels or []]
    if label_ops:
        update["labels"] = label_ops
    request("PUT", f"/2/issue/{key}", body={"fields": fields, "update": update})


def comment(key: str, body: str, files: Optional[List[str]] = None) -> str:
    """Comment on ``key`` from Markdown, attaching and showing files. Returns the comment id."""
    names = attach(key, files) if files else []
    wiki = _embed_missing(md_to_wiki(body), names)
    return request("POST", f"/2/issue/{key}/comment", body={"body": wiki})["id"]


def transitions(key: str) -> List[Json]:
    """Available transitions for ``key``."""
    return (request("GET", f"/3/issue/{key}/transitions") or {}).get("transitions", [])


def transition(key: str, target: str) -> str:
    """Move ``key`` by target status name or transition name. Returns the new status."""
    wanted = target.strip().lower()
    options = transitions(key)
    match = next((t for t in options if t["to"]["name"].lower() == wanted), None)
    match = match or next((t for t in options if t["name"].lower() == wanted), None)
    if match is None:
        names = ", ".join(f"{t['name']} -> {t['to']['name']}" for t in options)
        raise JiraError(f"{key}: no transition to '{target}'. Available: {names}")
    request("POST", f"/3/issue/{key}/transitions", body={"transition": {"id": match["id"]}})
    return request("GET", f"/3/issue/{key}", query={"fields": "status"})["fields"]["status"]["name"]


def link(link_type: str, inward: str, outward: str) -> None:
    """Link two issues. For Blocks, ``inward`` blocks ``outward``."""
    request(
        "POST",
        "/3/issueLink",
        body={
            "type": {"name": link_type},
            "inwardIssue": {"key": inward},
            "outwardIssue": {"key": outward},
        },
    )


def check() -> str:
    """Confirm the token can read LPT and edit an issue (a no-op edit)."""
    latest = search(f"project = {PROJECT} ORDER BY created DESC", limit=1)
    if not latest:
        raise JiraError(f"No issues visible in {PROJECT}")
    key = latest[0]["key"]
    request("PUT", f"/2/issue/{key}", body={"update": {}}, query={"notifyUsers": "false"})
    return key


# CLI ------------------------------------------------------------------------

def _read_body(path: Optional[str]) -> Optional[str]:
    """Body text from a file, or stdin when the path is ``-``."""
    if path is None:
        return None
    if path == "-":
        return sys.stdin.read()
    return Path(path).read_text(encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    """CLI parser."""
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("check", help="confirm read and write access to LPT")

    p = sub.add_parser("search", help="search with JQL")
    p.add_argument("jql")
    p.add_argument("--max", type=int, default=50)

    p = sub.add_parser("get", help="show one issue")
    p.add_argument("key")
    p.add_argument("--json", action="store_true")

    p = sub.add_parser("create", help="create an LPT issue")
    p.add_argument("--type", required=True, help="Bug, Story, Task, ...")
    p.add_argument("--summary", required=True)
    p.add_argument("--body-file", required=True, help="Markdown file, or - for stdin")
    p.add_argument("--priority")
    p.add_argument("--labels", default="", help="comma-separated")
    p.add_argument("--attach", nargs="*", default=[])

    p = sub.add_parser("edit", help="change fields on an issue")
    p.add_argument("key")
    p.add_argument("--summary")
    p.add_argument("--body-file")
    p.add_argument("--priority")
    p.add_argument("--add-label", action="append", default=[])
    p.add_argument("--remove-label", action="append", default=[])

    p = sub.add_parser("comment", help="comment on an issue")
    p.add_argument("key")
    p.add_argument("--body-file", required=True)
    p.add_argument("--attach", nargs="*", default=[])

    p = sub.add_parser("attach", help="attach files")
    p.add_argument("key")
    p.add_argument("files", nargs="+")

    p = sub.add_parser("transitions", help="list transitions")
    p.add_argument("key")

    p = sub.add_parser("transition", help="move an issue")
    p.add_argument("key")
    p.add_argument("--to", required=True, help="target status or transition name")

    p = sub.add_parser("link", help="link two issues")
    p.add_argument("--type", required=True, help="Blocks, Relates, Duplicate, ...")
    p.add_argument("--inward", required=True, help="for Blocks: the blocker")
    p.add_argument("--outward", required=True, help="for Blocks: the blocked issue")
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    """CLI entrypoint. Returns the process exit code."""
    args = build_parser().parse_args(argv)
    try:
        if args.cmd == "check":
            print(f"jira: ok (read and edit {check()})")
        elif args.cmd == "search":
            for issue in search(args.jql, args.max):
                print(_issue_line(issue))
        elif args.cmd == "get":
            issue = get(args.key)
            print(json.dumps(issue, indent=2) if args.json else format_issue(issue))
        elif args.cmd == "create":
            labels = [label for label in args.labels.split(",") if label]
            key = create(args.type, args.summary, _read_body(args.body_file) or "",
                         args.priority, labels, args.attach)
            print(f"{key}\t{SITE}/browse/{key}")
        elif args.cmd == "edit":
            edit(args.key, args.summary, _read_body(args.body_file), args.priority,
                 args.add_label, args.remove_label)
            print(f"edited {args.key}")
        elif args.cmd == "comment":
            print(f"commented on {args.key} ({comment(args.key, _read_body(args.body_file) or '', args.attach)})")
        elif args.cmd == "attach":
            print("\n".join(attach(args.key, args.files)))
        elif args.cmd == "transitions":
            for item in transitions(args.key):
                print(f"{item['id']}\t{item['name']}\t-> {item['to']['name']}")
        elif args.cmd == "transition":
            print(f"{args.key} is now {transition(args.key, args.to)}")
        elif args.cmd == "link":
            link(args.type, args.inward, args.outward)
            print(f"linked {args.inward} {args.type} {args.outward}")
    except JiraError as err:
        print(f"jira: {err}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
