#!/usr/bin/env bash
#
# SessionStart hook: put AGENTS.md §Rule Compliance in force before the first
# tool call, and shout if AGENTS.md has lost its routing.
#
# Wire it up in .claude/settings.json:
#
#   "hooks": {
#     "SessionStart": [
#       { "hooks": [ { "type": "command",
#                      "command": "bash \"$CLAUDE_PROJECT_DIR/.agents/hooks/rule-compliance.sh\"" } ] }
#     ]
#   }
#
# A markdown rule only binds an agent that reads the file. This hook is the
# mechanism: the directive reaches context on every session, whether or not the
# agent decided to open AGENTS.md.

set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

python3 - "$ROOT" <<'PY' 2>/dev/null || exit 0
import json, os, sys

root = sys.argv[1]
agents = os.path.join(root, "AGENTS.md")

DIRECTIVE = """AGENTS.md §Rule Compliance is in force for this session.

- Read AGENTS.md end to end, then run its Session Start reads, before the first tool call.
- Before the first production-code edit: name the Task Routing group this task falls into, and read every rule and skill that group names — in this session, at its `.agents/skills/` path.
- That routing holds for every later turn of this session, including the approval gate and the three Completion steps.
- Name the files you read. Token budget, session length, and "the change looks correct" are not exemptions."""

try:
    body = open(agents, encoding="utf-8").read()
except OSError:
    body = None

if body is None:
    out = {
        "systemMessage": "AGENTS.md is missing — this session has no project routing.",
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": (
                "AGENTS.md was not found at %s. The project routing, approval gate, and "
                "Completion steps are unavailable. Tell the user before doing project work; "
                "reinstall the agent layer with ag-agent-rules setup.sh." % agents
            ),
        },
    }
elif "## Rule Compliance" not in body:
    out = {
        "systemMessage": "AGENTS.md has no §Rule Compliance section — it may have been overwritten.",
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": (
                "AGENTS.md exists but carries no §Rule Compliance section, so its routing is "
                "probably gone — another tool's managed block overwriting the file is the "
                "known cause. Read AGENTS.md before project work and report the damage to the "
                "user instead of proceeding as if there were no rules.\n\n" + DIRECTIVE
            ),
        },
    }
else:
    out = {
        "suppressOutput": True,
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": DIRECTIVE,
        },
    }

print(json.dumps(out))
PY
