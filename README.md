# SDKUITestHelper

Fluent UI test helpers for XCTest that work with SwiftUI, UIKit, and AppKit accessibility elements.

![Swift 6](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2015%20%7C%20macOS%2012%20%7C%20tvOS%2015%20%7C%20visionOS%201-blue.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)

## Why SDKUITestHelper

`SDKUITestHelper` wraps `XCUIApplication` and `XCUIElement` in a typed, chainable API so UI tests are easier to read and maintain.

Instead of long raw XCTest query chains, you can write:

```swift
app.button("login")
    .isExisting()
    .isHittable()
    .tap()
```

## Features

- Chainable assertions and interactions for common UI test flows.
- Typed wrappers for buttons, labels, links, and switches.
- Convenience app lookup API for element selection by identifier and index.
- Swift 6 language mode enabled.
- Swift Package Manager-first setup.

## Requirements

- Swift 6+
- iOS 15+
- macOS 12+
- tvOS 15+
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
            .tap()

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
- `element(_:)`, `element(_:at:)`
- `navigationElement(at:)`, `navigationElement(in:at:)`

Element assertions/interactions (`SDKUITestElement`):

- `isExisting(timeout:)`
- `isNotExisting()`
- `validate(title:)`
- `validate(isEnabled:)`
- `validate(isSelected:)`
- `wait(forSeconds:)`
- `isHittable()`
- `isNotHittable()`
- `tap()`

Switch-specific (`SDKUITestSwitch`):

- `isOn()`
- `isOff()`
- custom `tap()` handling for nested SwiftUI switch elements

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
    .tap()
    .isOn()
```

### Navigation element

```swift
app.navigationElement(in: "Details", at: 0)
    .isExisting()
    .tap()
```

## Contributing

Pull requests are welcome. If you plan larger API or behavior changes, opening an issue first is appreciated.
