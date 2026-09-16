import XCTest

/// The whole app is the default lookup scope, so every lookup declared in
/// `SDKUILookupScope` is available directly on `XCUIApplication`.
extension XCUIApplication: SDKUILookupScope {
    public var lookupRoot: XCUIElement { self }
}

public extension XCUIApplication {
    /// Returns a lookup scope limited to the window with the given title.
    ///
    /// Use this when the same control exists in more than one window and an
    /// app-wide query would be ambiguous.
    ///
    /// ```swift
    /// app.window("Repository Search").searchField()
    ///     .isExisting()
    ///     .universalClick()
    /// ```
    ///
    /// - Parameter title: Title of the window, as shown in its title bar.
    /// - Returns: A `SDKUITestWindow`.
    func window(_ title: String) -> SDKUITestWindow {
        SDKUITestWindow(window: windows[title])
    }
}
