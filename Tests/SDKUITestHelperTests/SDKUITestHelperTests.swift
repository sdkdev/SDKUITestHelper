import Testing
import XCTest
@testable import SDKUITestHelper

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

/// Compile-time check of the public lookup API.
///
/// The queries need a running app, so this is never executed — it fails the
/// build instead if a lookup is renamed or an app-level lookup stops being
/// reachable after a change to `SDKUILookupScope`.
@MainActor
private func lookupAPIRemainsAvailable() {
    let app = XCUIApplication()

    // App-scoped lookups.
    _ = app.button("identifier")
    _ = app.button("identifier", at: 1)
    _ = app.button(labelContaining: "text")
    _ = app.link("identifier")
    _ = app.link("identifier", at: 1)
    _ = app.toggle("identifier")
    _ = app.label("identifier")
    _ = app.textField("identifier")
    _ = app.secureTextField("identifier")
    _ = app.searchField()
    _ = app.element("identifier")
    _ = app.element("identifier", at: 1)
    _ = app.navigationElement(at: 0)
    _ = app.navigationElement(in: "identifier", at: 0)

    // The same lookups, scoped to one window.
    let window = app.window("Window")
    _ = window.button("identifier")
    _ = window.button(labelContaining: "text")
    _ = window.searchField()
    _ = window.element("identifier")
    _ = window.element

    // Interactions.
    _ = app.button("identifier").tap()
    _ = app.button("identifier").universalClick()
    _ = app.toggle("identifier").universalClick()
}
