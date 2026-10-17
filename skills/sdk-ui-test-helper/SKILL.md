---
name: sdk-ui-test-helper
description: Write and fix XCUITest UI tests with the SDKUITestHelper package - fluent `app.button(...)` / `app.toggle(...)` lookups, chainable assertions, `universalClick()` for macOS and iOS from one chain, window-scoped lookups, SwiftUI switch handling. Use whenever a test target imports SDKUITestHelper or the user asks for UI tests on iOS, macOS, or visionOS.
metadata:
  short-description: Fluent XCUITest helpers for SwiftUI, UIKit and AppKit
---

# SDKUITestHelper

## Goal

Write UI tests as short, readable chains on typed wrappers instead of raw `XCUIElementQuery`
code and `XCTAssert` boilerplate. Every lookup returns a wrapper whose assertions and actions
return `Self`, so a test reads as one chain per element: look up, assert presence, interact,
assert the result.

## Setup

* Add the package to the **UI test target only**. Never link it into the app target.
* `import SDKUITestHelper` next to `import XCTest`.
* Platforms: iOS 15+, macOS 12+, visionOS 1+. Swift 6 language mode.
* Tests are `XCTestCase` subclasses. The wrappers are `@MainActor`; XCTest runs UI tests on
  the main thread, so no extra isolation annotations are needed in test methods.

## Canonical test

```swift
import XCTest
import SDKUITestHelper

final class LoginUITests: XCTestCase {
    func testLoginFlow() {
        let app = XCUIApplication()
        app.launch()

        app.textField("username")
            .isExisting()
            .universalClick()
            .typeText("sascha")

        app.button("login")
            .isExisting()
            .isHittable()
            .universalClick()

        app.label("welcome-title")
            .isExisting()
            .validate(title: "Welcome")
    }
}
```

Chain order: **lookup -> `isExisting()` -> `isHittable()` (before interacting) -> action -> assertion.**
Always start a chain with `isExisting()`. It waits up to 5 seconds, so it doubles as the
synchronization point; the other assertions do not wait.

## Lookups

All lookups take an **accessibility identifier**, not a visible label.

| Lookup | Use when |
| --- | --- |
| `app.button("id")` | A single button with that identifier. |
| `app.button("id", at: i)` | Several buttons legitimately share an identifier (list rows). |
| `app.button(labelContaining: "text")` | The button has no identifier or a runtime-composed title. Exact identifiers are preferred; the match is case- and diacritic-sensitive. |
| `app.link("id")`, `app.link("id", at: i)` | Tappable links (SwiftUI `Link`, attributed text links). |
| `app.toggle("id")` | Switches and SwiftUI `Toggle`. Returns `SDKUITestSwitch`. |
| `app.label("id")` | Static text; pair with `validate(title:)`. |
| `app.textField("id")`, `app.secureTextField("id")` | Text input; pair with `typeText(_:)`. |
| `app.searchField()` | The system search bar from `.searchable`. Takes no identifier. |
| `app.element("id")`, `app.element("id", at: i)` | Anything else (cells, containers, overlays) when only the shared assertions are needed. |
| `app.navigationElement(at: i)` | A navigation bar button by index. |
| `app.navigationElement(in: "bar-id", at: i)` | Same, inside a specific navigation bar when several can be on screen. |

Rules:

* Prefer an identifier lookup over `labelContaining:`. If a control has no identifier, add
  one in the app rather than matching on its label.
* Use the `at:` variants only when the identifier is intentionally repeated. An index on a
  unique identifier hides a bug in the app's accessibility tree.
* Use `element(_:)` as the fallback, not the default. A typed wrapper gives a better failure
  message and, for switches, different behaviour.

## Interactions: `universalClick()` over `tap()`

Use `universalClick()` for every pointer interaction. It clicks on macOS and taps on
every other platform, so one chain works in an iOS and a macOS test target.

On macOS a synthesized `tap()` is no longer delivered reliably to AppKit controls (the event
takes seconds to synthesize and the control never acts on it), while a click still works.
`tap()` stays available and always performs `XCUIElement.tap()`; use it only in a test
that must keep that exact behaviour, for example a test known to be iOS-only that relies on
touch semantics.

Never call `universalClick()` on a raw `XCUIElement` from a test. It is internal to the
package; go through a wrapper.

## Assertions and waiting

| Method | Behaviour |
| --- | --- |
| `isExisting(timeout:)` | Waits for existence, default 5 s. Fails if the element never appears. |
| `isNotExisting()` | Immediate check that the element is gone. |
| `isNotExisting(timeout:)` | Waits for disappearance. Use after dismissing sheets, alerts, overlays. |
| `wait(forSeconds:)` | Same as `isExisting(timeout:)`, named for when the wait is the point. Default 2 s. |
| `isHittable()`, `isNotHittable()` | Visible and not obscured. Check before interacting. |
| `validate(title:)` | Exact label match. |
| `validate(isEnabled:)`, `validate(isSelected:)` | Control state. |

Waiting is done with these timeouts. Never use `sleep`, `Thread.sleep`, `XCTWaiter`, or
`waitForExistence` directly in a test that uses this package.

## Switches

`app.toggle("id")` returns `SDKUITestSwitch`, which adds `isOn()` and `isOff()`. They read
the element value as `"1"` or `"0"`.

Its `tap()` and `universalClick()` look for a nested switch element first, because a SwiftUI
`Toggle` exposes the real switch as a child. UIKit `UISwitch` and AppKit `NSSwitch` have no
child and are interacted with directly. Do not query `.switches` manually; the wrapper handles
both cases.

```swift
app.toggle("notifications")
    .isExisting()
    .isOff()
    .universalClick()
    .isOn()
```

## Window scoping (macOS)

An app-level lookup searches every window. On macOS with several windows open, the same
identifier can exist in more than one of them, and the query becomes ambiguous or hits the
wrong window. Scope the lookup with `app.window("Window Title")`, which offers the same lookups
restricted to that window:

```swift
app.window("Repository Search").searchField()
    .isExisting()
    .universalClick()
    .typeText("devinbox")
```

`app.window("Title").element` is the window itself, for assertions on the window rather
than its content, for example `.isExisting(timeout: 5)` after opening it. The title is the
text in the window's title bar.

## Identifiers on the app side

The lookups only work when the app sets identifiers. When adding a test for a control that
has none, add the identifier in the app code:

* SwiftUI: `.accessibilityIdentifier("login")`
* UIKit: `button.accessibilityIdentifier = "login"`
* AppKit: `button.setAccessibilityIdentifier("login")`

Identifiers are stable, lowercase, kebab-case strings that describe the role
(`"login"`, `"settings-row"`, `"error-banner"`). They are never localized text and never
change with the control's title.

## Anti-patterns to rewrite

When you see raw XCTest code in a target that imports this package, rewrite it:

```swift
// Before
app.buttons["save"].tap()
// After
app.button("save")
    .isExisting()
    .universalClick()

// Before
XCTAssertTrue(app.staticTexts["title"].waitForExistence(timeout: 5))
XCTAssertEqual(app.staticTexts["title"].label, "Welcome")
// After
app.label("title")
    .isExisting()
    .validate(title: "Welcome")

// Before
XCTAssertEqual(app.switches["sync"].value as? String, "1")
// After
app.toggle("sync")
    .isExisting()
    .isOn()

// Before
sleep(2)
XCTAssertFalse(app.otherElements["loading"].exists)
// After
app.element("loading")
    .isNotExisting(timeout: 2)
```

## Reference

The package README lists the complete API under "API Overview" and documents the
tap-versus-click behaviour under "Tapping vs. clicking". Every public method also carries a
doc comment with a usage snippet.
