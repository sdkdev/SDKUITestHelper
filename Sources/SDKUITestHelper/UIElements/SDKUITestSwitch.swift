//
//  SDKUITestSwitch.swift
//
//
//  Created by Sascha Kratochvil on 24.10.23.
//

import Foundation
import XCTest

/// A switch element with assertions for its on/off state.
///
/// This wrapper also customizes `tap()` to better support SwiftUI toggles that
/// expose a nested switch element.
///
/// The switch value is interpreted as `"1"` for on and `"0"` for off, matching
/// the value representation used by `XCUIElement`.
///
/// ```swift
/// app.toggle("notifications")
///     .isExisting()
///     .isOff()
///     .tap()
///     .isOn()
/// ```
public class SDKUITestSwitch: SDKUITestElement {
    override var typeName: String { "Switch" }

    private var wrappedValue: String {
        return (element.value as? String) ?? "-1"
    }

    /// Verifies that the switch is on.
    ///
    /// ```swift
    /// app.toggle("notifications")
    ///     .isOn()
    /// ```
    ///
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func isOn() -> Self {
        XCTAssertEqual(wrappedValue, "1", "\(typeName) should be on but is off.")
        return self
    }

    /// Verifies that the switch is off.
    ///
    /// ```swift
    /// app.toggle("notifications")
    ///     .isOff()
    /// ```
    ///
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func isOff() -> Self {
        XCTAssertEqual(wrappedValue, "0", "\(typeName) should be off but is on.")
        return self
    }

    /// Taps the switch.
    ///
    /// SwiftUI toggles can expose a nested switch element, so this method prefers the nested switch when present.
    ///
    /// ```swift
    /// app.toggle("notifications")
    ///     .isOff()
    ///     .tap()
    ///     .isOn()
    /// ```
    ///
    /// - Returns: The same element wrapper for chaining.
    override public func tap() -> Self {
        if element.switches.firstMatch.exists {
            // Search in SwiftUI `View` for the real switch to tap on.
            element.switches.firstMatch.tap()
        } else {
            // Tap on a `UIKit` `UISwitch`.
            element.tap()
        }
        return self
    }
}
