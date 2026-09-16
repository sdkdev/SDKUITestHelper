# SDKUITestHelper

Fluent UI test helpers for XCTest that work with SwiftUI, UIKit, and AppKit accessibility elements.

![Swift 6](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2015%20%7C%20macOS%2012%20%7C%20visionOS%201-blue.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)

## Why SDKUITestHelper

`SDKUITestHelper` wraps `XCUIApplication` and `XCUIElement` in a typed, chainable API so UI tests are easier to read and maintain.

Instead of long raw XCTest query chains, you can write:

```swift
app.button("login")
    .isExisting()
    .isHittable()
    .universalClick()
```

## Features

- Chainable assertions and interactions for common UI test flows.
- Typed wrappers for buttons, labels, links, and switches.
- Convenience app lookup API for element selection by identifier and index.
- `universalClick()` for interactions that work on macOS and iOS from the same chain.
- Swift 6 language mode enabled.
- Swift Package Manager-first setup.

## Requirements

- Swift 6+
- iOS 15+
- macOS 12+
- visionOS 1+

## Installation

### Swift Package Manager

In Xcode:

1. `File` -> `Add Package Dependencies...`
2. Add this repository URL.
3. Select your preferred version rule and add `SDKUITestHelper` to your UI test target.

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sascha/SDKUITestHelper.git", from: "0.1.0")
]
```

## Quick Start

```swift
import XCTest
import SDKUITestHelper

final class LoginUITests: XCTestCase {
    func testLoginFlow() {
        let app = XCUIApplication()
        app.launch()

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

## API Overview

`XCUIApplication` extension:

- `button(_:)`, `button(_:at:)`
- `link(_:)`, `link(_:at:)`
- `toggle(_:)`
- `label(_:)`
- `textField(_:)`
- `secureTextField(_:)`
- `element(_:)`, `element(_:at:)`
- `navigationElement(at:)`, `navigationElement(in:at:)`

Element assertions/interactions (`SDKUITestElement`):

- `isExisting(timeout:)`
- `isNotExisting()`
- `isNotExisting(timeout:)`
- `validate(title:)`
- `validate(isEnabled:)`
- `validate(isSelected:)`
- `wait(forSeconds:)`
- `isHittable()`
- `isNotHittable()`
- `tap()`
- `universalClick()`
- `typeText(_:)` (text field wrapper)

`XCUIElement` extension:

- `universalClick()`

Switch-specific (`SDKUITestSwitch`):

- `isOn()`
- `isOff()`
- custom `tap()` and `universalClick()` handling for nested SwiftUI switch elements

## Tapping vs. clicking

`tap()` always performs `XCUIElement.tap()`. `universalClick()` clicks on macOS and taps
on every other platform, so one chain works in an iOS and a macOS test target.

Prefer `universalClick()` whenever the tests run on macOS: as of macOS 27 a synthesized
tap is no longer delivered reliably to AppKit controls — the event takes seconds to
synthesize and the control never acts on it — while a click still works. `tap()` keeps its
existing behaviour for tests that rely on it.

It is available on the wrappers and on `XCUIElement` itself, so raw queries can use the
same call:

```swift
app.windows["Search"].searchFields.firstMatch.universalClick()
```

## More Examples

### Indexed lookup

```swift
app.element("settings-row", at: 2)
    .isExisting()
    .isHittable()
```

### Switch flow

```swift
app.toggle("notifications")
    .isExisting()
    .isOff()
    .universalClick()
    .isOn()
```

### Navigation element

```swift
app.navigationElement(in: "Details", at: 0)
    .isExisting()
    .universalClick()
```

## Contributing

Pull requests are welcome. If you plan larger API or behavior changes, opening an issue first is appreciated.
