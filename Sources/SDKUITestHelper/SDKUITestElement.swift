//
//  SDKUITestElement.swift
//
//
//  Created by Sascha Kratochvil on 18.11.23.
//

import Foundation
import XCTest

/// A generic element for the UITest helper.
///
/// This type provides the minimum shared functionality every wrapped UI test element supports.
/// Most assertion and interaction helpers return `Self`, which makes the API
/// suitable for fluent UI test chains.
///
/// ```swift
/// app.element("profile-header")
///     .isExisting()
///     .isHittable()
///     .tap()
/// ```
@MainActor
public class SDKUITestElement: SDKUIElement {
    /// Type name of the SDKUITestElement
    var typeName: String { "Unknown" }

    /// The original `XCUIElement` element.
    public let element: XCUIElement

    init(element: XCUIElement) {
        self.element = element
    }

    /// Verifies that the element exists within the timeout.
    ///
    /// This is usually the first assertion to make before interacting with a UI
    /// element that may appear asynchronously.
    ///
    /// ```swift
    /// app.element("loading-result")
    ///     .isExisting(timeout: 10)
    /// ```
    ///
    /// - Parameter timeout: The number of seconds to wait before failing.
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func isExisting(timeout: TimeInterval = 5.0) -> Self {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "\(typeName) with identifier \(element.identifier) doesn't exist.")
        return self
    }

    /// Verifies that the element does not exist.
    ///
    /// Use this to confirm that a sheet, alert, or transient UI element has been
    /// dismissed.
    ///
    /// ```swift
    /// app.element("error-banner")
    ///     .isNotExisting()
    /// ```
    ///
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func isNotExisting() -> Self {
        XCTAssertFalse(element.exists, "\(typeName) with identifier \(element.identifier) exists.")
        return self
    }

    /// Verifies that the element disappears within the timeout.
    ///
    /// Use this when UI dismissal is asynchronous, such as after tapping
    /// a button that closes a sheet or alert.
    ///
    /// ```swift
    /// app.element("loading-overlay")
    ///     .isNotExisting(timeout: 4)
    /// ```
    ///
    /// - Parameter timeout: The number of seconds to wait for non-existence.
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func isNotExisting(timeout: TimeInterval) -> Self {
        XCTAssertTrue(element.waitForNonExistence(timeout: timeout), "\(typeName) with identifier \(element.identifier) still exists.")
        return self
    }

    /// Verifies that the element label matches the expected title.
    ///
    /// This is primarily useful for static text, buttons, and navigation items
    /// whose visible label should match a known value.
    ///
    /// ```swift
    /// app.label("status")
    ///     .validate(title: "Completed")
    /// ```
    ///
    /// - Parameter title: Expected title of the element.
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func validate(title: String) -> Self {
        XCTAssertEqual(element.label, title, "\(typeName) with identifier \(element.identifier) has label \(element.label) instead of \(title).")
        return self
    }

    /// Verifies whether the element is enabled.
    ///
    /// Use this to assert whether a control can currently be interacted with.
    ///
    /// ```swift
    /// app.button("submit")
    ///     .validate(isEnabled: false)
    /// ```
    ///
    /// - Parameter isEnabled: The expected value for enabled state.
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func validate(isEnabled: Bool) -> Self {
        XCTAssertEqual(element.isEnabled, isEnabled, "\(typeName) enabled state is not \(isEnabled).")
        return self
    }

    /// Verifies whether the element is selected.
    ///
    /// This is most often used for tabs, segmented controls, and custom selectable
    /// controls that expose selection through accessibility.
    ///
    /// ```swift
    /// app.element("settings-tab")
    ///     .validate(isSelected: true)
    /// ```
    ///
    /// - Parameter isSelected: The expected value for selected state.
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func validate(isSelected: Bool) -> Self {
        XCTAssertEqual(element.isSelected, isSelected, "\(typeName) selected state is not \(isSelected).")
        return self
    }

    /// Waits for the element to exist.
    ///
    /// Unlike `isExisting(timeout:)`, this method communicates intent more clearly
    /// when the wait itself is the important part of the test setup.
    ///
    /// ```swift
    /// app.element("sync-finished")
    ///     .wait(forSeconds: 3)
    ///     .validate(title: "Done")
    /// ```
    ///
    /// - Parameter seconds: The number of seconds the test should wait.
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func wait(forSeconds seconds: TimeInterval = 2.0) -> Self {
        XCTAssertTrue(element.waitForExistence(timeout: seconds), "\(typeName) with identifier \(element.identifier) doesn't appear.")
        return self
    }

    /// Verifies that the element is hittable.
    ///
    /// An element may exist but still be obscured or outside the visible area.
    /// This check is useful before performing user interactions.
    ///
    /// ```swift
    /// app.button("continue")
    ///     .isExisting()
    ///     .isHittable()
    /// ```
    ///
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func isHittable() -> Self {
        XCTAssertTrue(element.isHittable, "\(typeName) with identifier \(element.identifier) is not hittable.")
        return self
    }

    /// Verifies that the element is not hittable.
    ///
    /// Use this to assert that a control is hidden, disabled by an overlay, or
    /// otherwise not available for interaction.
    ///
    /// ```swift
    /// app.button("continue")
    ///     .isNotHittable()
    /// ```
    ///
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func isNotHittable() -> Self {
        XCTAssertFalse(element.isHittable, "\(typeName) with identifier \(element.identifier) is hittable.")
        return self
    }

    /// Taps the wrapped accessibility element.
    ///
    /// This method performs the standard XCTest tap action and returns the same
    /// wrapper so the interaction can remain part of a chain. Tests that also
    /// run on macOS should prefer `universalClick()`, because macOS 27 no longer
    /// delivers synthesized taps to AppKit controls.
    ///
    /// ```swift
    /// app.button("save")
    ///     .isHittable()
    ///     .tap()
    /// ```
    ///
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func tap() -> Self {
        element.tap()
        return self
    }

    /// Performs the primary pointer interaction for the current platform.
    ///
    /// This is the cross-platform counterpart to `tap()`: it clicks on macOS and
    /// taps everywhere else, so the same chain works in an iOS and a macOS test
    /// target. Prefer it over `tap()` for new tests.
    ///
    /// ```swift
    /// app.button("save")
    ///     .isHittable()
    ///     .universalClick()
    /// ```
    ///
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func universalClick() -> Self {
        element.universalClick()
        return self
    }
}
