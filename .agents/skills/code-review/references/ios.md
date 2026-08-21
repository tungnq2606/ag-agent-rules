# iOS — `ios/**`

Deployment target 15.1. Pods install with `RCT_NEW_ARCH_ENABLED=1` and `USE_FRAMEWORKS=static` — iOS is on a different architecture from Android. Schemes: `uniscore`, `uniscoreDev`, `uniscoreStag`, `uniscoreBeta`, plus `LiveScoreWidgetExtension`.

## Blocking

- API newer than iOS 15.1 used without an availability check.
- Entitlement or capability added that the feature does not need, or added without telling the user.
- Secret or key in `Info.plist` or a build setting.
- Provisioning profile, `.p8`, `.p12`, or signing password committed.
- `GoogleService-Info.plist` wired to the wrong scheme.
- App Transport Security relaxed outside a debug-only configuration.

## Swift / Objective-C

- UI work off the main thread, or heavy work on it.
- Retain cycle in a closure capturing `self` strongly.
- Force-unwrapped optional that can be `nil` at runtime.
- Notification observer or KVO added with no removal.
- Bridged method assuming a thread the caller does not guarantee.

## Podfile

- Dependency added without `Podfile.lock` committed.
- Deployment target raised for one pod, pulling the whole app up.
- `use_frameworks!` mode changed — it interacts with static linking and breaks other pods.
- Pods changed without a reinstall. `yarn pod-i` or `yarn fix:ios:pod`.

## Widget

`LiveScoreWidgetExtension` reads data shared with the app.

- Shared data shape changed without checking the widget still reads it.
- Widget target not built after a change to shared code. The app building proves nothing about the widget.
- App Group identifier changed on one side only.

## Firebase and push

- Push capability, APNs key, or entitlement changed without testing on a real device — the simulator does not deliver remote push.
- Foreground presentation not handled: iOS suppresses the banner while the app is active unless it is presented explicitly.

## Verification

Build the affected scheme, then run the behavior on a device or simulator per `.ai/rules/device-matrix.md`. A change touching both platforms verified only on iOS is half-verified — say so.
