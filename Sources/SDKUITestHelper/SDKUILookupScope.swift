//
//  SDKUILookupScope.swift
//
//
//  Created by Sascha Kratochvil on 16.09.26.
//

import Foundation
import XCTest

@MainActor
func indexedElement(from query: XCUIElementQuery, at index: Int, description: String) -> XCUIElement {
    guard index >= 0 else {
        XCTFail("\(description) requested with invalid negative index \(index).")
        return query.firstMatch
    }

    return query.element(boundBy: index)
}

/// A part of the UI that element lookups are performed in.
///
/// `XCUIApplication` searches the whole app, while `SDKUITestWindow` narrows the
/// search to a single window. Both offer the same lookup API, so a test can
/// scope a query without changing how it reads.
///
/// ```swift
/// app.button("save")                      // anywhere in the app
/// app.window("Settings").button("save")   // only in the Settings window
/// ```
@MainActor
public protocol SDKUILookupScope {
    /// The element whose descendants are searched.
    var lookupRoot: XCUIElement { get }
}

public extension SDKUILookupScope {
    /// Returns a button wrapper for the matching accessibility identifier.
    ///
    /// Use this when the scope contains a single matching button and you want to
    /// chain assertions or actions on it.
    ///
    /// ```swift
    /// app.button("save")
    ///     .isExisting()
    ///     .isHittable()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestButton`.
    func button(_ identifier: String) -> SDKUITestButton {
        SDKUITestButton(element: lookupRoot.buttons[identifier])
    }

    /// Returns a button wrapper for the matching accessibility identifier at a specific index.
    ///
    /// This is useful when multiple buttons share the same accessibility identifier
    /// and you need to target a specific occurrence.
    ///
    /// ```swift
    /// app.button("list-item-action", at: 1)
    ///     .isExisting()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Parameter index: Index in the matching query.
    /// - Returns: A `SDKUITestButton`.
    func button(_ identifier: String, at index: Int) -> SDKUITestButton {
        let query = lookupRoot.descendants(matching: .any)[identifier].buttons
        return SDKUITestButton(element: indexedElement(from: query, at: index, description: "Button with identifier \(identifier)"))
    }

    /// Returns the first button whose label contains the given text.
    ///
    /// Use this for buttons that carry no accessibility identifier, such as the
    /// items AppKit builds for context menus or buttons whose title is composed
    /// at runtime. Prefer the identifier-based lookups whenever an identifier is
    /// available — they are exact and cheaper to evaluate.
    ///
    /// The match is case- and diacritic-sensitive.
    ///
    /// ```swift
    /// app.button(labelContaining: "Unsubscribe")
    ///     .isExisting()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter text: Substring the button label must contain.
    /// - Returns: A `SDKUITestButton`.
    func button(labelContaining text: String) -> SDKUITestButton {
        let query = lookupRoot.buttons.matching(NSPredicate(format: "label CONTAINS %@", text))
        return SDKUITestButton(element: query.firstMatch)
    }

    /// Returns a link wrapper for the matching accessibility identifier.
    ///
    /// Use this for tappable links exposed through accessibility in SwiftUI or UIKit.
    ///
    /// ```swift
    /// app.link("terms-of-service")
    ///     .isExisting()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestLink`.
    func link(_ identifier: String) -> SDKUITestLink {
        SDKUITestLink(element: lookupRoot.links[identifier])
    }

    /// Returns a link wrapper for the matching accessibility identifier at a specific index.
    ///
    /// This variant is intended for screens where multiple links use the same
    /// accessibility identifier.
    ///
    /// ```swift
    /// app.link("learn-more", at: 0)
    ///     .isHittable()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Parameter index: Index in the matching query.
    /// - Returns: A `SDKUITestLink`.
    func link(_ identifier: String, at index: Int) -> SDKUITestLink {
        let query = lookupRoot.descendants(matching: .any)[identifier].links
        return SDKUITestLink(element: indexedElement(from: query, at: index, description: "Link with identifier \(identifier)"))
    }

    /// Returns a switch wrapper for the matching accessibility identifier.
    ///
    /// The returned wrapper adds convenience methods like `isOn()`, `isOff()`,
    /// and a custom interaction that also works for SwiftUI toggles.
    ///
    /// ```swift
    /// app.toggle("notifications")
    ///     .isExisting()
    ///     .isOff()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestSwitch`.
    func toggle(_ identifier: String) -> SDKUITestSwitch {
        SDKUITestSwitch(element: lookupRoot.switches[identifier])
    }

    /// Returns a label wrapper for the matching accessibility identifier.
    ///
    /// Labels are most useful for text assertions in UI tests.
    ///
    /// ```swift
    /// app.label("welcome-message")
    ///     .isExisting()
    ///     .validate(title: "Welcome back")
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestLabel`.
    func label(_ identifier: String) -> SDKUITestLabel {
        SDKUITestLabel(element: lookupRoot.staticTexts[identifier])
    }

    /// Returns a text field wrapper for the matching accessibility identifier.
    ///
    /// Use this for plain text input controls.
    ///
    /// ```swift
    /// app.textField("username")
    ///     .isExisting()
    ///     .universalClick()
    ///     .typeText("john")
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestTextField`.
    func textField(_ identifier: String) -> SDKUITestTextField {
        SDKUITestTextField(element: lookupRoot.textFields[identifier])
    }

    /// Returns a secure text field wrapper for the matching accessibility identifier.
    ///
    /// Use this for password or token input controls.
    ///
    /// ```swift
    /// app.secureTextField("token")
    ///     .isExisting()
    ///     .universalClick()
    ///     .typeText("secret")
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestTextField`.
    func secureTextField(_ identifier: String) -> SDKUITestTextField {
        SDKUITestTextField(element: lookupRoot.secureTextFields[identifier])
    }

    /// Returns the first search field wrapper in the scope.
    ///
    /// Use this for the system search bar provided by `.searchable`. When more
    /// than one window shows a search field, scope the lookup to a window so the
    /// match is unambiguous.
    ///
    /// ```swift
    /// app.window("Repository Search").searchField()
    ///     .isExisting()
    ///     .universalClick()
    ///     .typeText("query")
    /// ```
    ///
    /// - Returns: A `SDKUITestTextField`.
    func searchField() -> SDKUITestTextField {
        SDKUITestTextField(element: lookupRoot.searchFields.firstMatch)
    }

    /// Returns a generic element wrapper for the matching accessibility identifier.
    ///
    /// Use this when you do not care about a more specific control type and only
    /// need the shared assertions provided by `SDKUITestElement`.
    ///
    /// ```swift
    /// app.element("profile-header")
    ///     .isExisting()
    ///     .isHittable()
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Returns: A `SDKUITestElement`.
    func element(_ identifier: String) -> SDKUITestElement {
        SDKUITestElement(element: lookupRoot.descendants(matching: .any)[identifier])
    }

    /// Returns a generic element wrapper for the matching accessibility identifier at a specific index.
    ///
    /// Prefer this overload when the same identifier appears multiple times in the
    /// view hierarchy.
    ///
    /// ```swift
    /// app.element("list-row", at: 2)
    ///     .isExisting()
    ///     .isHittable()
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier.
    /// - Parameter index: Index in the matching query.
    /// - Returns: A `SDKUITestElement`.
    func element(_ identifier: String, at index: Int) -> SDKUITestElement {
        let query = lookupRoot.descendants(matching: .any).matching(identifier: identifier)
        return SDKUITestElement(element: indexedElement(from: query, at: index, description: "Element with identifier \(identifier)"))
    }

    /// Returns a navigation bar button at the given index.
    ///
    /// This can be useful for back buttons or toolbar-style navigation actions
    /// that are easier to address by position than by identifier.
    ///
    /// ```swift
    /// app.navigationElement(at: 0)
    ///     .isExisting()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter index: Index in the navigation bar button query.
    /// - Returns: A `SDKUITestElement`.
    func navigationElement(at index: Int) -> SDKUITestElement {
        SDKUITestElement(element: indexedElement(from: lookupRoot.navigationBars.buttons, at: index, description: "Navigation item"))
    }

    /// Returns a navigation bar button inside the given navigation bar at the given index.
    ///
    /// Use this when multiple navigation bars can appear during a test and you want
    /// to scope the lookup to a specific bar.
    ///
    /// ```swift
    /// app.navigationElement(in: "Details", at: 0)
    ///     .isExisting()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier of the navigation bar.
    /// - Parameter index: Index in the navigation bar button query.
    /// - Returns: A `SDKUITestElement`.
    func navigationElement(in identifier: String, at index: Int) -> SDKUITestElement {
        let query = lookupRoot.navigationBars[identifier].buttons
        return SDKUITestElement(element: indexedElement(from: query, at: index, description: "Navigation item in bar \(identifier)"))
    }
}
