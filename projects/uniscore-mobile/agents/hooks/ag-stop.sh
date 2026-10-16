#!/usr/bin/env bash
# Antigravity Stop adapter. Once per conversation: if THIS conversation wrote a file
# under src/ or lib/ (replace_file_content / write_to_file), the tree still has
# uncommitted src/lib changes, and the agent never ran `yarn verify` via run_command,
# keep the agent going so it verifies and ends with a "Test:" list.
python3 -c '
import json, os, re, subprocess, sys
d = json.load(sys.stdin)
ws = (d.get("workspacePaths") or [""])[0]
cid = d.get("conversationId", "")
tp = os.path.expanduser(d.get("transcriptPath", ""))
def allow():
    print("{}"); sys.exit(0)
if not ws or not cid: allow()
mark = f"/tmp/uniscore-stop-{cid}"
if os.path.exists(mark): allow()
wrote = ran = False
try:
    for line in open(tp):
        try: e = json.loads(line)
        except Exception: continue
        for c in e.get("tool_calls") or []:
            name, args = c.get("name", ""), json.dumps(c.get("args", {}))
            if name == "run_command" and "yarn verify" in args: ran = True
            if re.search(r"replace|write|edit", name) and (ws + "/src/" in args or ws + "/lib/" in args): wrote = True
except OSError:
    allow()
if ran or not wrote: allow()
if not subprocess.run(["git", "-C", ws, "status", "--porcelain", "--", "src", "lib"], capture_output=True, text=True).stdout.strip(): allow()
open(mark, "w").close()
print(json.dumps({"decision": "continue", "reason": "AGENTS.md Completion: this conversation changed src/lib but `yarn verify` was not run. Run it, then end with a \"Test:\" list, or state why verification is not possible."}))
'
