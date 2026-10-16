---
name: maestro-e2e
description: Write, run, and debug Maestro E2E flows under `.maestro/` on iOS and Android, and report pass/fail per case. Use when a UI change needs on-device proof, when adding or fixing a flow, or when a flow fails and you must decide whether the test or the app is wrong.
---

A flow is evidence only when it is **grounded**: every selector exists in `src/`, every expected state comes from the spec, and every failure has been reproduced by hand before anyone calls it an app bug. The reference run is US-5256 (`.maestro/README.md`, "Verified (baseline)"): 13 cases, 13/13 on iOS and Android. A later failure is a regression until shown otherwise.

`.maestro/` is local only: it sits in `.git/info/exclude` and is never committed or pushed. `testID`s added to `src/` are feature code and may be committed.

## Standard workflow

1. **Spec.** Write the case table first: start state, action, expected state per case. Take expected states from the ticket or `.maestro/README.md`, and check them against the commit logic in the source. Done when every case has one expected state for every control it touches.
2. **Selectors.** Expose state in the `testID` (`<scope>_<control>_on|off`) and add it in the component when missing. `git grep` every `id:` you write; an id with no hit in `src/` is invented. Check each one on the live hierarchy too, since iOS can hide a `testID` (see "iOS hierarchy").
3. **Flow.** One flow per case: `launch.yaml` → open the screen → reset to a known state → act → assert every control's state. Shared steps go in `.maestro/subflows/`. Name the entity under test (by label or `childOf`); never rely on "first row" or `index: 0` over account data. End every flow with `takeScreenshot: <ID>-end`. A case that survives an app restart waits one favorites sync (`subflows/wait-sync.yaml`, 50 s) before asserting.
4. **Prepare both devices (clean).** Stop every running test first. Clear the Mac clipboard (`pbcopy < /dev/null`; both emulators sync it and the text lands in the search box). Then:
   - iOS: `xcrun simctl terminate/uninstall`, `shutdown`, `boot`, `privacy <udid> reset all`, `install <DebugStag .app>`. A stuck system dialog (ATT, "Open in app?") is cleared by this reboot. Rebuild only when the code changed: `npx react-native run-ios --scheme uniscoreStag --udid <udid> --no-packager`.
   - Android: `adb uninstall`, then `adb install` the release APK (`yarn build:stag:apk`; uninstall the debug build first, the signatures differ).
   Done when both devices show a fresh install. Never say "fresh install" without checking the setup trace: it must show onboarding being walked, not skipped.
5. **Run both platforms in parallel**, one `run.sh` per device, one command at a time per device (the MCP server and the CLI, or two runs, cannot share a device). Per device: `TARGET=.maestro/setup/first-run.yaml .maestro/run.sh <ios|android>` once (onboarding, ATT, consent, first-run tooltip), then `.maestro/run.sh <ios|android> --format junit --output <file> --test-output-dir <dir>`. Do not touch the devices while a run is going. Done when the whole folder passes in one run on both platforms.
6. **Triage each failure.** Screenshot the failing step and read `commands.json` and `screen-hierarchy/`. Reproduce the same steps by hand (a scratch flow with `takeScreenshot` after each step). If the app reaches the expected state by hand, the test is wrong: fix the timing or the selector, never the assertion. If the app is wrong by hand too, stop and report an app bug with the screenshot and the spec line. A pass is not proof either: check it is not a window artifact (asserted before a later sync wipes the state). Done when every failure is labelled test defect or app defect, with evidence.
7. **Report: an HTML page, pass/fail per case only.** Copy `.maestro/reports/2026-10-13.json` to a new config, fill it in the reader's language (Vietnamese for this team): `scope`, per case a plain `title`, `why`, concrete `steps`, expected state, and `not_covered`. Leave `fixes` and `app_issues` empty unless an app defect was found: test defects fixed along the way do not belong in the report. Run `python3 -I .maestro/scripts/report.py <config>.json .maestro/reports/<date>.html`, publish it as an Artifact (update the same `url` on re-runs), and give the link. Done when someone who never read the flows can tell which cases ran and whether each passed. Before sending the file, check it: `head -n 4` must show `<!doctype html>`, `lang="vi"` and `<meta charset="utf-8">` (without the charset, Telegram and other viewers decode Vietnamese as Latin-1 and show garbage), and `#zoom[hidden] { display: none; }` must exist in `report.py` (without it the `display: grid` on `#zoom` overrides `hidden`, and a translucent overlay covers the whole page). Both bugs hit the 2026-10-13 match report; any change to the template needs the same two checks and a look at the page on a phone.

## Traps

### iOS hierarchy

- **Merged labels.** A pressable or tooltip merges its children's text into one label (`Leagues` becomes the tab's whole label; a tooltip reads `Customize notifications … Got it`). Match with a regex such as `".*Leagues.*"`. A tap on a merged element hits its centre, which may not be the button inside; tap by `point` and note the device it was measured on.
- **`containsChild` fails on merged rows.** Use `childOf: {id: <row id>, text: <row label>}`.
- **Hidden `testID`.** Some wrapped buttons (onboarding `Continue`) do not expose their `testID` on iOS. Fall back to the visible text.
- **System alerts hide the app.** While "Open in <app>?" or the ATT prompt is up, the hierarchy holds only the alert, so `Following` is "not visible". Answer the alert first, in setup only.
- **Stale overlays.** A dismissed web dialog (the ad-consent CMP) stays in the accessibility tree. `when: visible` is then true forever, and the tap lands on whatever sits underneath. Tap an overlay only in a flow where it really appears (fresh install), and confirm with a screenshot.

### Timing

- **Cold-start deep links are dropped.** `launchApp` then `openLink` leaves the app on Home. Wait for a Home element (the `Following` tab) before `openLink`.
- **Absent elements cost 6-7 s.** An `optional: true` tap, `when: visible`, or `when: notVisible` on an element that is not there waits that long on every run. For a prompt only some devices show, gate it on an env flag (`when: true: ${typeof FLAG !== 'undefined' && FLAG == 'true'}`), which evaluates instantly (`IOS_OPEN_PROMPT=true` for a real iPhone).
- **Sheets and animations.** A tap while a bottom sheet slides in is lost silently. `waitForAnimationToEnd` before and after taps inside a sheet (`subflows/master-off.yaml`).
- **Favorites sync every 45 s** (`time_interval_favorite`). A restart assertion made seconds after relaunch can pass while the state is lost at the next sync. Wait 50 s first.

### State and data

- Flows keep app state between runs, so no flow needs an uninstall: reset the entity to a known state inside each flow, and never depend on what the test account follows. Only `setup/first-run.yaml` deals with a fresh install, and it is safe to repeat.
- Favorites survive an app restart signed in or out; only an uninstall loses them for a signed-out user.
- A first-run feature tooltip left open blocks every later flow: on Android it is a Modal, so the hierarchy holds only the tooltip. A cascade of identical `id … not visible` failures means "tooltip still up", not 13 bugs.
- Point taps are per platform: iOS merges the tooltip (tap a point), Android exposes the button text (tap the text). Split with `when: platform:`.
- One list can render two layouts for the same row type (search: `LeagueMatches` vs `SearchLeagueItem`). An id carried by only one layout makes `index: 0` pick the wrong entity.
- Onboarding's `Continue` stays disabled until a team or league is picked; setup stars the first league.

## Tooling

- CLI: `export PATH="$HOME/.maestro/bin:$PATH"`, then `.maestro/run.sh <ios|android> --device <udid>` (`TARGET=<flow or dir>` for a subset). It sets `APP_ID` and `DEEPLINK_SCHEME` per platform. `timeout` does not exist on macOS and `rm -rf` is blocked: move old output dirs aside instead.
- Traces: `--test-output-dir <dir>`, then `<flow>/commands.json` (status and duration per command) and `screen-hierarchy/`. MCP `run` returns only pass or fail, so use it for quick inline checks, not for triage.
- Screenshots: `takeScreenshot: <name>` takes a name relative to the output dir (an absolute path is rejected); `xcrun simctl io <udid> screenshot <file>` grabs the screen between runs.
- Report script: `.maestro/scripts/report.py` needs macOS `sips`; JUnit comes from `--format junit --output`.
- Android: run the release APK. A debug build loads JS from Metro and its cold start (13-14 s, 30 s+ under load) outlasts the Home wait.
- Setup of a new machine and the case tables: `.maestro/README.md`.
