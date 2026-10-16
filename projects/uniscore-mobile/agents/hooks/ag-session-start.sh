#!/usr/bin/env bash
# Antigravity adapter: reuse rule-compliance.sh (Claude format) and re-emit its
# text as injectSteps. Wired to SessionStart (App/IDE) and PreInvocation (CLI 1.4.0
# has no SessionStart). Injects once per conversation.
in=$(cat)
read -r ws cid < <(python3 -c '
import json,sys
d=json.loads(sys.argv[1]); print((d.get("workspacePaths") or [""])[0] or "-", d.get("conversationId") or "-")' "$in" 2>/dev/null)
[ "${ws:--}" = "-" ] && ws="$PWD"
if [ -n "${cid:-}" ] && [ "$cid" != "-" ]; then
  mark="/tmp/uniscore-rc-$cid"
  [ -e "$mark" ] && { echo '{}'; exit 0; }
  touch "$mark"
fi
CLAUDE_PROJECT_DIR="$ws" bash "$ws/.agents/hooks/rule-compliance.sh" 2>/dev/null | python3 -c '
import json,sys
try: d=json.load(sys.stdin)
except Exception: print("{}"); sys.exit(0)
t=d.get("hookSpecificOutput",{}).get("additionalContext","")
print(json.dumps({"injectSteps":[{"systemMessage":{"systemMessage":t}}]} if t else {}))'
