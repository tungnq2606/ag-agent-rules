#!/usr/bin/env python3
"""
Audit a React Native / Expo repository for React Native Skia readiness,
common integration mistakes, and Skia-specific animation anti-patterns.

Examples:
  python3 scripts/audit_skia_repo.py --root . --format markdown
  python3 scripts/audit_skia_repo.py --root . --format json
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

SKIA_PACKAGE = "@shopify/react-native-skia"
REANIMATED_PACKAGE = "react-native-reanimated"
WORKLETS_PACKAGE = "react-native-worklets"
RNGH_PACKAGE = "react-native-gesture-handler"

IGNORE_DIRS = {
    ".git",
    "node_modules",
    "dist",
    "build",
    "coverage",
    ".expo",
    ".next",
    ".turbo",
    ".gradle",
    ".idea",
    "ios/Pods",
}

SOURCE_SUFFIXES = {".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs"}
BABEL_CANDIDATES = [
    "babel.config.js",
    "babel.config.cjs",
    "babel.config.mjs",
    ".babelrc",
    ".babelrc.js",
    ".babelrc.cjs",
    ".babelrc.json",
]
ROOT_FILE_CANDIDATES = [
    "App.tsx",
    "App.ts",
    "App.js",
    "index.tsx",
    "index.ts",
    "index.js",
    "src/App.tsx",
    "src/App.ts",
    "src/App.js",
    "app/_layout.tsx",
    "app/_layout.ts",
    "app/index.tsx",
    "app/index.ts",
]

FEATURE_PATTERNS = {
    "skia_import": re.compile(r"@shopify/react-native-skia"),
    "canvas": re.compile(r"\bCanvas\b"),
    "load_skia_web": re.compile(r"\bLoadSkiaWeb\b"),
    "with_skia_web": re.compile(r"\bWithSkiaWeb\b"),
    "paragraph": re.compile(r"\bParagraph\b|\bParagraphBuilder\b"),
    "shader": re.compile(r"\bRuntimeEffect\b|\bShader\b|\bRuntimeShader\b"),
    "picture": re.compile(r"\bPicture\b"),
    "atlas": re.compile(r"\bAtlas\b"),
    "texture_hooks": re.compile(r"\buseTexture\b|\buseImageAsTexture\b|\busePictureAsTexture\b"),
    "use_image": re.compile(r"\buseImage\b"),
    "use_video": re.compile(r"\buseVideo\b"),
    "make_image_from_view": re.compile(r"\bmakeImageFromView\b"),
    "skottie": re.compile(r"\bSkottie\b"),
    "gesture_api": re.compile(r"\bGesture\b|\bGestureDetector\b|\bGestureHandlerRootView\b"),
    "reanimated_values": re.compile(r"\buseSharedValue\b|\buseDerivedValue\b|\bwithTiming\b|\bwithSpring\b|\bwithRepeat\b"),
    "create_animated_component": re.compile(r"\bcreateAnimatedComponent\b"),
    "use_animated_props": re.compile(r"\buseAnimatedProps\b"),
    "interpolate_color": re.compile(r"\binterpolateColor\b"),
    "android_warmup": re.compile(r"\bandroidWarmup\b"),
    "runtime_shader": re.compile(r"\bRuntimeShader\b"),
}

FINDING_SEVERITY_ORDER = {"error": 0, "warning": 1, "info": 2}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit a React Native or Expo repo for React Native Skia compatibility and common pitfalls."
    )
    parser.add_argument(
        "--root",
        default=".",
        help="Repository root to inspect. Defaults to the current directory.",
    )
    parser.add_argument(
        "--format",
        choices=("markdown", "json"),
        default="markdown",
        help="Output format. Defaults to markdown.",
    )
    parser.add_argument(
        "--max-hits",
        type=int,
        default=6,
        help="Maximum file hits to show per feature in markdown output. Defaults to 6.",
    )
    return parser.parse_args()


def read_text_if_exists(path: Path) -> Optional[str]:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return None
    except UnicodeDecodeError:
        return None


def load_json(path: Path) -> Optional[Dict[str, Any]]:
    text = read_text_if_exists(path)
    if text is None:
        return None
    try:
        value = json.loads(text)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Error: could not parse JSON at {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise SystemExit(f"Error: expected a JSON object at {path}.")
    return value


def iter_source_files(root: Path) -> Iterable[Path]:
    for current_root, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
        current_path = Path(current_root)
        for filename in files:
            path = current_path / filename
            if path.suffix in SOURCE_SUFFIXES:
                yield path


def dependency_map(package_json: Dict[str, Any]) -> Dict[str, str]:
    deps: Dict[str, str] = {}
    for section in ("dependencies", "devDependencies", "peerDependencies"):
        values = package_json.get(section, {})
        if isinstance(values, dict):
            for name, spec in values.items():
                if isinstance(name, str) and isinstance(spec, str):
                    deps.setdefault(name, spec)
    return deps


def find_package_manager(root: Path, package_json: Dict[str, Any]) -> str:
    package_manager = package_json.get("packageManager")
    if isinstance(package_manager, str) and package_manager:
        return package_manager.split("@", 1)[0]
    if (root / "bun.lockb").exists() or (root / "bun.lock").exists():
        return "bun"
    if (root / "pnpm-lock.yaml").exists():
        return "pnpm"
    if (root / "yarn.lock").exists():
        return "yarn"
    if (root / "package-lock.json").exists():
        return "npm"
    return "unknown"


def extract_version_pair(spec: Optional[str]) -> Optional[Tuple[int, int]]:
    if not spec:
        return None
    match = re.search(r"(\d+)\.(\d+)", spec)
    if not match:
        return None
    return int(match.group(1)), int(match.group(2))


def extract_major(spec: Optional[str]) -> Optional[int]:
    pair = extract_version_pair(spec)
    return None if pair is None else pair[0]


def parse_ios_target(root: Path) -> Optional[str]:
    text = read_text_if_exists(root / "ios" / "Podfile")
    if not text:
        return None
    match = re.search(r"platform\s*:ios\s*,\s*['\"](\d+(?:\.\d+)?)['\"]", text)
    return match.group(1) if match else None


def parse_android_min_sdk(root: Path) -> Optional[int]:
    candidates = [
        root / "android" / "app" / "build.gradle",
        root / "android" / "app" / "build.gradle.kts",
        root / "android" / "build.gradle",
        root / "android" / "build.gradle.kts",
    ]
    patterns = [
        re.compile(r"\bminSdkVersion\s*=?\s*(\d+)"),
        re.compile(r"\bminSdk\s*=?\s*(\d+)"),
    ]
    for path in candidates:
        text = read_text_if_exists(path)
        if not text:
            continue
        for pattern in patterns:
            match = pattern.search(text)
            if match:
                try:
                    return int(match.group(1))
                except ValueError:
                    pass
    return None


def scan_sources(root: Path) -> Dict[str, Any]:
    feature_hits = {name: [] for name in FEATURE_PATTERNS}
    total = 0
    file_texts: Dict[str, str] = {}

    for path in iter_source_files(root):
        total += 1
        text = read_text_if_exists(path)
        if text is None:
            continue
        rel = str(path.relative_to(root))
        file_texts[rel] = text
        for name, pattern in FEATURE_PATTERNS.items():
            if pattern.search(text):
                feature_hits[name].append(rel)

    return {
        "total_source_files_scanned": total,
        "feature_hits": feature_hits,
        "file_texts": file_texts,
    }


def has_web_surface(root: Path, package_json: Dict[str, Any], feature_hits: Dict[str, List[str]]) -> bool:
    scripts = package_json.get("scripts", {})
    if isinstance(scripts, dict) and "web" in scripts:
        return True
    if feature_hits["load_skia_web"] or feature_hits["with_skia_web"]:
        return True
    for candidate in ("index.web.tsx", "index.web.ts", "index.web.jsx", "index.web.js"):
        if (root / candidate).exists():
            return True
    return False


def has_expo(package_json: Dict[str, Any]) -> bool:
    deps = dependency_map(package_json)
    return "expo" in deps


def read_babel_config(root: Path) -> Optional[Tuple[str, str]]:
    for candidate in BABEL_CANDIDATES:
        path = root / candidate
        text = read_text_if_exists(path)
        if text is not None:
            return candidate, text
    return None


def parse_babel_plugins(text: str) -> Optional[List[str]]:
    match = re.search(r"plugins\s*:\s*\[(.*?)\]", text, re.DOTALL)
    if not match:
        return None
    body = match.group(1)
    return re.findall(r"['\"]([^'\"]+)['\"]", body)


def has_gesture_root(root: Path, file_texts: Dict[str, str]) -> bool:
    for rel in ROOT_FILE_CANDIDATES:
        text = file_texts.get(rel)
        if text and "GestureHandlerRootView" in text:
            return True
    return any("GestureHandlerRootView" in text for text in file_texts.values())


def trusted_dependency_enabled(package_json: Dict[str, Any]) -> Optional[bool]:
    trusted = package_json.get("trustedDependencies")
    if trusted is None:
        return None
    if isinstance(trusted, list):
        return SKIA_PACKAGE in trusted
    return None


def yarn_scripts_enabled(root: Path) -> Optional[bool]:
    text = read_text_if_exists(root / ".yarnrc.yml")
    if text is None:
        return None
    match = re.search(r"^\s*enableScripts\s*:\s*(\S+)\s*$", text, re.MULTILINE)
    if not match:
        return None
    value = match.group(1).strip().lower().strip("'\"")
    if value == "false":
        return False
    if value == "true":
        return True
    return None


def add_finding(findings: List[Dict[str, Any]], severity: str, code: str, message: str, files: Optional[Sequence[str]] = None) -> None:
    entry: Dict[str, Any] = {
        "severity": severity,
        "code": code,
        "message": message,
    }
    if files:
        entry["files"] = list(files)
    findings.append(entry)


def analyse_antipatterns(findings: List[Dict[str, Any]], feature_hits: Dict[str, List[str]], file_texts: Dict[str, str]) -> None:
    skia_files = set(feature_hits["skia_import"])

    for rel in sorted(skia_files):
        text = file_texts[rel]

        if FEATURE_PATTERNS["create_animated_component"].search(text) or FEATURE_PATTERNS["use_animated_props"].search(text):
            add_finding(
                findings,
                "warning",
                "SKIA_WRAPPED_AS_ANIMATED_COMPONENT",
                "This file uses createAnimatedComponent/useAnimatedProps alongside Skia. Skia supports passing shared/derived values directly to Skia props.",
                [rel],
            )

        if "interpolateColor" in text and "@shopify/react-native-skia" in text:
            add_finding(
                findings,
                "warning",
                "SKIA_COLOR_INTERPOLATION",
                "This file uses Reanimated interpolateColor alongside Skia. Prefer Skia interpolateColors for Skia colour props.",
                [rel],
            )

        if "makeImageFromView" in text and "collapsable={false}" not in text.replace(" ", ""):
            add_finding(
                findings,
                "warning",
                "SNAPSHOT_COLLAPSABLE_MISSING",
                "This file uses makeImageFromView but does not obviously set collapsable={false} on the captured root view.",
                [rel],
            )

        if "RuntimeShader" in text and "PixelRatio" not in text:
            add_finding(
                findings,
                "info",
                "RUNTIME_SHADER_NO_PIXEL_RATIO",
                "This file uses RuntimeShader without an obvious PixelRatio-based supersampling path. Review output crispness on high-density screens.",
                [rel],
            )

        if "Gesture." in text and "useMemo(" not in text:
            add_finding(
                findings,
                "info",
                "GESTURE_NOT_MEMOISED",
                "This file defines gesture objects without an obvious useMemo wrapper. Memoising gestures reduces reattachment work.",
                [rel],
            )

        if "androidWarmup" in text and any(token in text for token in ("useSharedValue", "withTiming", "withRepeat", "opacity", "transparent")):
            add_finding(
                findings,
                "warning",
                "ANDROID_WARMUP_DYNAMIC_SCENE",
                "This file enables androidWarmup in a scene that also looks animated or translucent. androidWarmup is intended for static, fully opaque canvases.",
                [rel],
            )


def analyse_repo(root: Path) -> Dict[str, Any]:
    package_json_path = root / "package.json"
    package_json = load_json(package_json_path)
    if package_json is None:
        return {
            "root": str(root.resolve()),
            "environment": {},
            "usage": {},
            "findings": [
                {
                    "severity": "error",
                    "code": "NO_PACKAGE_JSON",
                    "message": f"No package.json found at {package_json_path}. Point --root at a React Native or Expo repository.",
                }
            ],
            "recommendations": [
                "Run the audit against the repository root that contains package.json."
            ],
        }

    deps = dependency_map(package_json)
    pm = find_package_manager(root, package_json)
    source_scan = scan_sources(root)
    feature_hits = source_scan["feature_hits"]
    file_texts = source_scan["file_texts"]
    ios_target = parse_ios_target(root)
    android_min_sdk = parse_android_min_sdk(root)
    expo = has_expo(package_json)
    web_surface = has_web_surface(root, package_json, feature_hits)

    findings: List[Dict[str, Any]] = []
    recommendations: List[str] = []

    skia_spec = deps.get(SKIA_PACKAGE)
    rn_spec = deps.get("react-native")
    react_spec = deps.get("react")
    reanimated_spec = deps.get(REANIMATED_PACKAGE)
    worklets_spec = deps.get(WORKLETS_PACKAGE)
    rngh_spec = deps.get(RNGH_PACKAGE)

    skia_pair = extract_version_pair(skia_spec)
    rn_pair = extract_version_pair(rn_spec)
    react_major = extract_major(react_spec)
    reanimated_major = extract_major(reanimated_spec)

    if skia_spec is None:
        add_finding(
            findings,
            "warning",
            "SKIA_NOT_INSTALLED",
            f"{SKIA_PACKAGE} is not declared in package.json.",
        )
        recommendations.append(f"Install {SKIA_PACKAGE} before applying Skia-specific patches.")

    if rn_pair and react_major is not None and skia_pair:
        if (rn_pair < (0, 79) or react_major < 19) and (skia_pair[0] > 1 or (skia_pair[0] == 1 and skia_pair[1] > 12)):
            add_finding(
                findings,
                "error",
                "VERSION_COMPATIBILITY",
                "This app appears to be on an older React / React Native line but a newer React Native Skia version. Current docs say older apps should stay on @shopify/react-native-skia <= 1.12.4.",
            )
            recommendations.append("Pin @shopify/react-native-skia to <= 1.12.4 or upgrade React/React Native to the current supported line.")
        elif rn_pair >= (0, 79) and react_major >= 19 and skia_pair[0] == 1 and skia_pair[1] <= 12:
            add_finding(
                findings,
                "info",
                "OLD_SKIA_ON_NEW_STACK",
                "The app looks new enough for the current React Native Skia line but is pinned to an older Skia version.",
            )

    if ios_target:
        try:
            if float(ios_target) < 14.0:
                add_finding(
                    findings,
                    "error",
                    "IOS_TARGET_TOO_LOW",
                    f"Podfile target is iOS {ios_target}. Current React Native Skia docs require iOS 14+.",
                )
        except ValueError:
            pass

    if android_min_sdk is not None:
        if android_min_sdk < 21:
            add_finding(
                findings,
                "error",
                "ANDROID_MIN_SDK_TOO_LOW",
                f"Android minSdk is {android_min_sdk}. Current React Native Skia docs require API 21+.",
            )
        elif feature_hits["use_video"] and android_min_sdk < 26:
            add_finding(
                findings,
                "error",
                "ANDROID_VIDEO_MIN_SDK_TOO_LOW",
                f"Video support is used but Android minSdk is {android_min_sdk}. React Native Skia video requires API 26+.",
            )

    if pm == "bun":
        trusted = trusted_dependency_enabled(package_json)
        if trusted is False:
            add_finding(
                findings,
                "warning",
                "BUN_TRUSTED_DEPENDENCIES",
                "Bun project does not trust @shopify/react-native-skia in trustedDependencies. The Skia postinstall step can be blocked.",
            )
            recommendations.append("Add @shopify/react-native-skia to trustedDependencies and reinstall.")

    if pm == "yarn":
        scripts_enabled = yarn_scripts_enabled(root)
        if scripts_enabled is False:
            add_finding(
                findings,
                "warning",
                "YARN_SCRIPTS_DISABLED",
                "Yarn Berry has enableScripts=false. React Native Skia's postinstall step will be skipped.",
            )
            recommendations.append("Enable scripts in .yarnrc.yml and reinstall dependencies.")

    if feature_hits["reanimated_values"] and reanimated_spec is None:
        add_finding(
            findings,
            "error",
            "REANIMATED_MISSING",
            "Source files use Reanimated APIs but react-native-reanimated is not declared in package.json.",
        )

    if reanimated_major is not None and reanimated_major >= 4 and worklets_spec is None:
        add_finding(
            findings,
            "error",
            "WORKLETS_MISSING",
            "Reanimated 4 is installed but react-native-worklets is not declared. Current docs require it.",
        )
        recommendations.append("Install react-native-worklets and rebuild native apps.")

    babel = read_babel_config(root)
    if babel:
        babel_path, babel_text = babel
        plugins = parse_babel_plugins(babel_text)
        if reanimated_major is not None and reanimated_major >= 4:
            if "react-native-worklets/plugin" not in babel_text and not expo:
                add_finding(
                    findings,
                    "warning",
                    "WORKLETS_PLUGIN_MISSING",
                    f"{babel_path} does not obviously include react-native-worklets/plugin. Community CLI apps need it, listed last.",
                )
            elif plugins is not None and plugins and plugins[-1] != "react-native-worklets/plugin":
                add_finding(
                    findings,
                    "warning",
                    "WORKLETS_PLUGIN_NOT_LAST",
                    f"{babel_path} includes react-native-worklets/plugin but it does not appear to be the last Babel plugin.",
                )
        if web_surface and reanimated_major is not None and reanimated_major >= 4 and "@babel/plugin-proposal-export-namespace-from" not in babel_text:
            add_finding(
                findings,
                "info",
                "WEB_EXPORT_NAMESPACE_PLUGIN_MISSING",
                f"{babel_path} does not obviously include @babel/plugin-proposal-export-namespace-from. Reanimated web docs recommend it for react-native-web builds.",
            )

    if feature_hits["gesture_api"] and rngh_spec is None:
        add_finding(
            findings,
            "error",
            "GESTURE_HANDLER_MISSING",
            "Source files use Gesture Handler APIs but react-native-gesture-handler is not declared in package.json.",
        )

    if rngh_spec is not None and not has_gesture_root(root, file_texts):
        add_finding(
            findings,
            "warning",
            "GESTURE_ROOT_MISSING",
            "GestureHandlerRootView was not found in likely root files. Gestures must live under a GestureHandlerRootView near the app root.",
        )

    if web_surface and skia_spec is not None and not (feature_hits["load_skia_web"] or feature_hits["with_skia_web"]):
        add_finding(
            findings,
            "warning",
            "SKIA_WEB_BOOTSTRAP_MISSING",
            "This looks like a web-capable app using Skia, but no LoadSkiaWeb / WithSkiaWeb usage was found.",
        )
        recommendations.append("Gate web rendering until CanvasKit loads via LoadSkiaWeb() or WithSkiaWeb.")

    scripts = package_json.get("scripts", {})
    if expo and web_surface and skia_spec is not None:
        setup_script_present = False
        if isinstance(scripts, dict):
            for value in scripts.values():
                if isinstance(value, str) and "setup-skia-web" in value:
                    setup_script_present = True
                    break
        if not setup_script_present:
            add_finding(
                findings,
                "info",
                "SETUP_SKIA_WEB_NOT_FOUND",
                "Expo web surface detected but no script mentioning setup-skia-web was found. Remember to rerun setup-skia-web after Skia upgrades unless CanvasKit comes from a CDN.",
            )

    analyse_antipatterns(findings, feature_hits, file_texts)

    if feature_hits["paragraph"]:
        recommendations.append("Use Paragraph for wrapped or multi-style text and keep font loading explicit.")
    if feature_hits["make_image_from_view"]:
        recommendations.append("Check every captured root view for collapsable={false}.")
    if feature_hits["runtime_shader"]:
        recommendations.append("Review RuntimeShader outputs on high-density screens and supersample if needed.")
    if feature_hits["atlas"]:
        recommendations.append("Verify Atlas is used only when many instances truly share one texture.")
    if feature_hits["picture"]:
        recommendations.append("Verify Picture is justified by a dynamic command list rather than simple retained-mode animation.")

    recommendations.extend([
        "Prefer shared/derived values directly on Skia props.",
        "Prefer transform/opacity style changes over layout-affecting animation.",
        "Memoise gestures and heavy derived geometry when possible.",
    ])

    deduped_recommendations: List[str] = []
    seen: set[str] = set()
    for item in recommendations:
        if item not in seen:
            seen.add(item)
            deduped_recommendations.append(item)

    environment = {
        "package_manager": pm,
        "expo": expo,
        "web_surface": web_surface,
        "versions": {
            "react-native": rn_spec,
            "react": react_spec,
            SKIA_PACKAGE: skia_spec,
            REANIMATED_PACKAGE: reanimated_spec,
            WORKLETS_PACKAGE: worklets_spec,
            RNGH_PACKAGE: rngh_spec,
        },
        "platform_targets": {
            "ios": ios_target,
            "android_min_sdk": android_min_sdk,
        },
        "babel_config": babel[0] if babel else None,
    }

    usage = {
        "total_source_files_scanned": source_scan["total_source_files_scanned"],
        "feature_hits": feature_hits,
    }

    findings.sort(key=lambda item: (FINDING_SEVERITY_ORDER[item["severity"]], item["code"]))

    return {
        "root": str(root.resolve()),
        "environment": environment,
        "usage": usage,
        "findings": findings,
        "recommendations": deduped_recommendations,
    }


def format_hits(files: Sequence[str], max_hits: int) -> str:
    if not files:
        return "none"
    visible = list(files[:max_hits])
    suffix = ""
    if len(files) > max_hits:
        suffix = f", +{len(files) - max_hits} more"
    return ", ".join(visible) + suffix


def render_markdown(report: Dict[str, Any], max_hits: int) -> str:
    lines: List[str] = []
    lines.append("# React Native Skia repo audit")
    lines.append("")
    lines.append(f"- **Root:** `{report['root']}`")

    environment = report.get("environment", {})
    usage = report.get("usage", {})
    findings = report.get("findings", [])
    recommendations = report.get("recommendations", [])

    if environment:
        versions = environment.get("versions", {})
        lines.append("")
        lines.append("## Environment")
        lines.append("")
        lines.append(f"- **Package manager:** `{environment.get('package_manager')}`")
        lines.append(f"- **Expo:** `{environment.get('expo')}`")
        lines.append(f"- **Web surface detected:** `{environment.get('web_surface')}`")
        if environment.get("babel_config"):
            lines.append(f"- **Babel config:** `{environment['babel_config']}`")
        ios_target = environment.get("platform_targets", {}).get("ios")
        android_min_sdk = environment.get("platform_targets", {}).get("android_min_sdk")
        if ios_target:
            lines.append(f"- **iOS target:** `{ios_target}`")
        if android_min_sdk is not None:
            lines.append(f"- **Android minSdk:** `{android_min_sdk}`")
        lines.append("- **Declared versions:**")
        for key, value in versions.items():
            if value:
                lines.append(f"  - `{key}`: `{value}`")

    if usage:
        lines.append("")
        lines.append("## Usage signals")
        lines.append("")
        lines.append(f"- **Source files scanned:** `{usage.get('total_source_files_scanned', 0)}`")
        feature_hits = usage.get("feature_hits", {})
        important = [
            "canvas",
            "paragraph",
            "shader",
            "picture",
            "atlas",
            "texture_hooks",
            "use_video",
            "make_image_from_view",
            "gesture_api",
            "load_skia_web",
            "with_skia_web",
        ]
        for name in important:
            hits = feature_hits.get(name, [])
            if hits:
                lines.append(f"- **{name}:** {format_hits(hits, max_hits)}")

    lines.append("")
    lines.append("## Findings")
    lines.append("")
    if not findings:
        lines.append("- No obvious issues found.")
    else:
        for finding in findings:
            prefix = finding["severity"].upper()
            code = finding["code"]
            message = finding["message"]
            extra = ""
            if finding.get("files"):
                extra = f" Files: {', '.join(finding['files'])}"
            lines.append(f"- **{prefix} [{code}]** {message}{extra}")

    if recommendations:
        lines.append("")
        lines.append("## Recommended next actions")
        lines.append("")
        for item in recommendations:
            lines.append(f"- {item}")

    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    report = analyse_repo(root)

    if args.format == "json":
        json.dump(report, sys.stdout, indent=2)
        sys.stdout.write("\n")
    else:
        sys.stdout.write(render_markdown(report, args.max_hits))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
