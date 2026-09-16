//
//  SDKUITestWindow.swift
//
//
//  Created by Sascha Kratochvil on 16.09.26.
//

import Foundation
import XCTest

/// A lookup scope limited to one window.
///
/// Multi-window apps often show the same control in more than one window — a
/// search field in the sidebar and in a dedicated search window, for example —
/// so an app-wide query is ambiguous. This scope offers the same lookup API as
/// `XCUIApplication`, restricted to the descendants of a single window.
///
/// ```swift
/// app.window("Repository Search").searchField()
///     .isExisting()
///     .universalClick()
///     .typeText("devinbox")
/// ```
@MainActor
public struct SDKUITestWindow: SDKUILookupScope {
    /// The window whose descendants are searched.
    public let lookupRoot: XCUIElement

    init(window: XCUIElement) {
        lookupRoot = window
    }

    /// The wrapped window itself, for assertions on the window rather than its content.
    ///
    /// ```swift
    /// app.window("DevInbox").element
    ///     .isExisting(timeout: 5)
    /// ```
    public var element: SDKUITestElement {
        SDKUITestElement(element: lookupRoot)
    }
}
