//
//  SDKUITestWindow.swift
//
//
//  Created by Sascha Kratochvil on 16.09.26.
//

import Foundation
import XCTest

/// Element lookups restricted to a single window.
///
/// Multi-window apps often show the same control in more than one window — a
/// search field in the sidebar and in a dedicated search window, for example —
/// so an app-wide query is ambiguous. This offers the same lookups as
/// `XCUIApplication`, searching only the descendants of one window.
///
/// Obtain one from `XCUIApplication.window(_:)`:
///
/// ```swift
/// app.window("Repository Search").searchField()
///     .isExisting()
///     .universalClick()
///     .typeText("devinbox")
/// ```
@MainActor
public struct SDKUITestWindow {
    /// The window whose descendants are searched.
    public let window: XCUIElement

    init(window: XCUIElement) {
        self.window = window
    }

    /// The window itself, for assertions on the window rather than its content.
    ///
    /// ```swift
    /// app.window("DevInbox").element
    ///     .isExisting(timeout: 5)
    /// ```
    public var element: SDKUITestElement {
        SDKUITestElement(element: window)
    }

    /// Returns a button wrapper for the matching accessibility identifier.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestButton`.
    public func button(_ identifier: String) -> SDKUITestButton {
        SDKUITestButton(element: window.buttons[identifier])
    }

    /// Returns a button wrapper for the matching accessibility identifier at a specific index.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Parameter index: Index in the matching query.
    /// - Returns: A `SDKUITestButton`.
    public func button(_ identifier: String, at index: Int) -> SDKUITestButton {
        let query = window.descendants(matching: .any)[identifier].buttons
        return SDKUITestButton(element: indexedElement(from: query, at: index, description: "Button with identifier \(identifier)"))
    }

    /// Returns the first button in the window whose label contains the given text.
    ///
    /// The match is case- and diacritic-sensitive.
    ///
    /// - Parameter text: Substring the button label must contain.
    /// - Returns: A `SDKUITestButton`.
    public func button(labelContaining text: String) -> SDKUITestButton {
        SDKUITestButton(element: window.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch)
    }

    /// Returns a link wrapper for the matching accessibility identifier.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestLink`.
    public func link(_ identifier: String) -> SDKUITestLink {
        SDKUITestLink(element: window.links[identifier])
    }

    /// Returns a switch wrapper for the matching accessibility identifier.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestSwitch`.
    public func toggle(_ identifier: String) -> SDKUITestSwitch {
        SDKUITestSwitch(element: window.switches[identifier])
    }

    /// Returns a label wrapper for the matching accessibility identifier.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestLabel`.
    public func label(_ identifier: String) -> SDKUITestLabel {
        SDKUITestLabel(element: window.staticTexts[identifier])
    }

    /// Returns a text field wrapper for the matching accessibility identifier.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestTextField`.
    public func textField(_ identifier: String) -> SDKUITestTextField {
        SDKUITestTextField(element: window.textFields[identifier])
    }

    /// Returns a secure text field wrapper for the matching accessibility identifier.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestTextField`.
    public func secureTextField(_ identifier: String) -> SDKUITestTextField {
        SDKUITestTextField(element: window.secureTextFields[identifier])
    }

    /// Returns the first search field in the window.
    ///
    /// This is the lookup to reach for when several windows are open and each
    /// has its own `.searchable` field, which makes `XCUIApplication.searchField()`
    /// ambiguous.
    ///
    /// ```swift
    /// app.window("Repository Search").searchField()
    ///     .isExisting()
    ///     .universalClick()
    ///     .typeText("query")
    /// ```
    ///
    /// - Returns: A `SDKUITestTextField`.
    public func searchField() -> SDKUITestTextField {
        SDKUITestTextField(element: window.searchFields.firstMatch)
    }

    /// Returns a generic element wrapper for the matching accessibility identifier.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestElement`.
    public func element(_ identifier: String) -> SDKUITestElement {
        SDKUITestElement(element: window.descendants(matching: .any)[identifier])
    }

    /// Returns a generic element wrapper for the matching accessibility identifier at a specific index.
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Parameter index: Index in the matching query.
    /// - Returns: A `SDKUITestElement`.
    public func element(_ identifier: String, at index: Int) -> SDKUITestElement {
        let query = window.descendants(matching: .any).matching(identifier: identifier)
        return SDKUITestElement(element: indexedElement(from: query, at: index, description: "Element with identifier \(identifier)"))
    }
}
