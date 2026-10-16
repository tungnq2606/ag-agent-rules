# Security Rules

Read this file when handling secrets, credentials, user data, authentication, deep links, WebViews, or persisted storage.

A shipped mobile app is a binary in the user's hands. Treat everything inside the JS bundle as readable by anyone who wants to read it.

## Secrets

Keep secrets out of the app entirely when the backend can hold them instead.

- Anything bundled into JS is extractable: `.env` files consumed at build time, `Config` constants, string literals. Bundling is not hiding.
- Keys that must ship (Firebase client keys, map keys) must be restricted server-side by bundle ID / SHA-256 fingerprint and by API scope.
- Anything with real privilege (payment, admin, signing) belongs behind an endpoint, never in the client.
- Keystore, provisioning profiles, `.p8`/`.p12`, service-account JSON, and signing passwords stay out of the repository. Read them from CI secrets or the local keychain.
- `google-services.json` and `GoogleService-Info.plist` are per-environment; verify the right one ships with the right variant.

When a secret has been committed: rotate it, then remove it. Removing it from the working tree does not un-publish it — it stays in git history and in every clone.

## Tokens and session state

- Access/refresh tokens go in the platform keychain (`react-native-keychain` or equivalent), not in plain MMKV or AsyncStorage.
- When MMKV holds session data, use an encrypted instance and a distinct instance ID from cache data, so clearing cache cannot clear credentials and vice versa.
- Clear every credential store on logout, including in-memory query caches that hold user data.
- Do not put tokens in URL query strings — they land in logs, analytics, and deep-link history.

## Logging and crash reporting

- Never log tokens, passwords, full API responses containing user data, email addresses, or device identifiers.
- Configure Sentry `beforeSend` to scrub request headers, bodies, and breadcrumb data before upload.
- Remove temporary diagnostic logging before completion. A log added to debug one issue becomes a leak the day the screen ships.
- Error messages shown in the UI must not carry backend internals — stack frames, SQL, hostnames, or raw provider errors.

## Untrusted input

Validate at the boundary where external data enters, and narrow before use.

- API responses are untrusted: the field you rely on can be absent, `null`, or the wrong shape. Narrow before dereferencing rather than trusting the declared type.
- Deep links and universal links are attacker-controllable: validate the route, the parameter types, and the user's permission to see the target before navigating. Never pass a link parameter straight into a request path.
- Push notification payloads are untrusted the same way — validate before acting on them.
- Use `unknown` (not `any`) for anything crossing the boundary, then narrow it.

## WebView

- Load only URLs on an allowlist; reject anything else.
- Keep `javaScriptEnabled` off unless the feature needs it.
- Never inject a token into page context via `injectedJavaScript`.
- Treat every `onMessage` payload as untrusted input.

## Network

- HTTPS only. Do not relax ATS on iOS or add a cleartext-permitted domain on Android for convenience; if a debug build needs it, scope it to the debug manifest.
- Consider certificate pinning for auth and payment endpoints; when pinned, ship a rotation plan or an app update becomes a hard outage.

## Sensitive screens

- Mark sensitive fields `secureTextEntry` and exclude them from autofill where inappropriate.
- Block screenshots on screens showing credentials or payment data (`FLAG_SECURE` on Android; a privacy overlay on iOS backgrounding).
- Clear sensitive values from the clipboard, and avoid copying tokens there at all.

## Dependencies

- Adding a dependency requires explicit user approval — a native dependency also enlarges the attack surface and the review burden.
- Before proposing one, check what it does at runtime: network calls, native permissions, background execution.
- New permissions in `AndroidManifest.xml` or `Info.plist` are a review trigger; declare only what the feature uses.

## Review triggers

Stop and review carefully — not just implement — when the change touches:

- authentication, session, or token handling;
- storage of user data;
- deep links, universal links, or push payload handling;
- WebView configuration;
- network security configuration or pinning;
- payment or purchase flows;
- new native permissions;
- anything reading or writing keystore, keychain, or signing material.

Report a finding here as CRITICAL and stop before implementation, per `.agents/skills/code-review/SKILL.md`.
