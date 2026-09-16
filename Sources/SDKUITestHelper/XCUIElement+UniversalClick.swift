//
//  XCUIElement+UniversalClick.swift
//
//
//  Created by Sascha Kratochvil on 16.09.26.
//

import Foundation
import XCTest

public extension XCUIElement {
    /// Performs the primary pointer interaction for the current platform.
    ///
    /// Use this instead of `tap()` in tests that run on macOS. Starting with
    /// macOS 27, a synthesized tap is no longer delivered reliably to AppKit
    /// controls — the event takes seconds to synthesize and the control never
    /// acts on it — while `click()` still works. `click()` exists only on
    /// macOS, so every other platform keeps using `tap()`.
    ///
    /// ```swift
    /// app.buttons["save"].universalClick()
    /// ```
    func universalClick() {
        #if os(macOS)
            click()
        #else
            tap()
        #endif
    }
}
