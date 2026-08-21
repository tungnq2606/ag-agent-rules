---
name: triage-crash
description: Triage a production crash, ANR, or Sentry issue. Use when given a stack trace, a Sentry link, a crash-rate regression, or a report that the app closes itself on some flow.
---

# Triage Crash

A crash report is evidence, not a diagnosis. The job is to turn it into a reproducible failure with a named cause before touching code.

## Workflow

1. **Read the report before the code.** Note: affected app version(s), platform and OS versions, device models, first-seen and last-seen, event count and user count, and whether the rate is rising.
2. **Decide whether it is new.** A crash that starts at one release points at that release's diff. A crash present for months at low volume is a different investigation and usually a different priority.
3. **Classify the layer** — see below. It determines where you look next.
4. **Confirm the stack is trustworthy.** An unsymbolicated native trace or a minified JS trace tells you almost nothing; fix the symbolication before reasoning about the frames.
5. **Reproduce.** Match the reported device class, OS version, locale, and app version. Reproduction on the affected environment is worth more than reading ten more frames.
6. **Name the cause** in one sentence: the state, the input, and the operation that fails. If you cannot, keep gathering evidence — do not ship a guarded guess.
7. **Fix the cause, minimally.** A null guard that hides a state bug turns a crash into wrong data, which is worse.
8. **Verify** per `.ai/rules/verification.md`, reproducing the original scenario and confirming it no longer fails.
9. **Report** the cause, the fix, the affected versions, and whether the fix needs a release or can wait.

## Classify the layer

| Signal in the trace | Layer | Where to look |
|---|---|---|
| JS frames, `TypeError`, `undefined is not an object` | JS | The screen or hook in the frames; recent diff on that path |
| `RCTFatal`, `facebook::react`, bridge/TurboModule frames | JS ↔ native boundary | Native module arguments, nullability, threading |
| Kotlin/Java frames, `NullPointerException`, `IllegalStateException` | Android native | Lifecycle, fragment/activity state, permission |
| Objective-C/Swift frames, `SIGSEGV`, `EXC_BAD_ACCESS` | iOS native | Retained/released object, main-thread requirement |
| `ANR`, `Application Not Responding`, watchdog termination | Main-thread block | Long synchronous work on the main or JS thread |
| `OutOfMemoryError`, growing memory before the crash | Memory | `.agents/skills/react-native-best-practices/SKILL.md` — memory references |

## Symbolication

A trace you cannot read is the first thing to fix, not something to work around.

- Confirm the Sentry release matches the crashing build exactly. A mismatched release is the most common reason frames stay minified.
- JS frames need the source map uploaded for that release; native iOS frames need the dSYM; Android native needs the debug symbols and, when R8 is on, the mapping file.
- When symbolication cannot be recovered for an old release, say so and reason from the report metadata instead of pretending the frames are meaningful.

## Common shapes

- **Crash only on one OS version** — a platform API behaving differently; check the API's availability and the version guard around it.
- **Crash only on first launch after update** — persisted state whose shape changed. Check the MMKV/storage read path and whether a migration was needed.
- **Crash only from a notification or a link** — an untrusted payload reaching navigation without validation. See `.ai/rules/security.md`.
- **Crash on returning from background** — state assumed live that the OS reclaimed, or a listener re-registered twice.
- **ANR on a specific screen** — synchronous work on the main thread: a large JSON parse, a synchronous storage read, or an unvirtualized list.
- **Rate jumps without a release** — a backend response shape changed. Check the service layer's narrowing, not the screen.

## Escalation

Route to `.agents/skills/plan-work/SKILL.md` when the fix turns out to need an architecture, data-flow, or shared-contract change, and get approval before implementing.

Report to the user immediately, before finishing the investigation, when the crash affects a released version at a rising rate — the release decision is theirs and it is time-sensitive.

## Rules

- Evidence before speculation. Separate what the report proves from what you infer.
- One hypothesis tested at a time. Changing several things to see what helps destroys the evidence.
- Do not add a broad try/catch to make a crash disappear.
- Remove temporary diagnostic logging before completion, and never log user data while investigating.
