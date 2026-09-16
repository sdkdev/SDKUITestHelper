# AGENTS.md

Guidance for coding agents working in this repository.

## Project Summary

- Package name: `SDKUITestHelper`
- Type: Swift Package Manager library
- Purpose: Fluent wrappers around `XCUIApplication` and `XCUIElement` for UI tests across SwiftUI/UIKit/AppKit accessibility surfaces.

## Current Baseline

- Swift tools: `6.2`
- Swift language mode: `v6`
- Minimum platforms:
  - iOS 15+
  - macOS 12+
  - visionOS 1+
- Version source of truth: numeric Git tags (semver format: `major.minor.patch`, no `v` prefix)

## Repository Layout

- `Sources/SDKUITestHelper/`
  - `SDKUITestElement.swift`: Base chainable assertions/actions
  - `SDKUIElement.swift`: Core protocol
  - `XCUIApplication+Extension.swift`: App-wide lookup API (`button`, `label`, `toggle`, etc.) plus `window(_:)`
  - `SDKUITestWindow.swift`: The same lookups, restricted to one window
  - `XCUIElement+UniversalClick.swift`: The one place the macOS `click` / non-macOS `tap` difference lives (internal)
  - `UIElements/`: Typed wrappers (`SDKUITestButton`, `SDKUITestLabel`, `SDKUITestLink`, `SDKUITestSwitch`)
- `Tests/SDKUITestHelperTests/`: Minimal placeholder tests plus a compile-time check of the public lookup API
- `.github/workflows/ci.yml`: PR build matrix (macOS + iOS 26)
- `.github/workflows/release.yml`: Auto-release on `main`

## Build And Validation

Use these commands from repo root:

- Package build/test:
  - `swift test`
- Xcode builds:
  - `xcodebuild -scheme SDKUITestHelper -destination 'platform=macOS' build`
  - `xcodebuild -scheme SDKUITestHelper -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build`

## Coding Conventions

- Keep public API fluent and chainable (`@discardableResult` where intended).
- Prefer clear Swift-style naming (already migrated from `get...` methods to concise methods).
- Do not reintroduce old `DFL` prefixes.
- Keep changes minimal and scoped; avoid broad refactors unless requested.
- Preserve Swift 6 compatibility and actor isolation correctness.

## Documentation Standards

- Public wrappers and extension methods should include:
  - short purpose statement
  - when-to-use guidance
  - compact usage snippet
- Keep README aligned with actual API names and platform support.

## CI And Release Expectations

### Pull Request workflow (`.github/workflows/ci.yml`)

- Runs on pull requests.
- Build-only matrix on `macos-26`.
- Explicitly selects `Xcode 26.3`.
- Targets: macOS, iOS Simulator 26.2.

### Release workflow (`.github/workflows/release.yml`)

- Trigger: push to `main`
- Behavior:
  1. Read latest numeric semver tag if present.
  2. If no tags exist, start at `0.1.0`.
  3. Bump patch version from the latest tag.
  4. Create numeric tag (no `v` prefix), push it, and create GitHub release.

Do not change tag format away from numeric semver unless explicitly requested.

## Safety Rules

- Never remove or rewrite workflows/release logic without user request.
- Do not delete source files unless the user explicitly asks for deletion.
- If unexpected staged/deleted files appear, stop and ask before committing.
