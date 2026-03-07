//
//  SDKUITestButton.swift
//
//
//  Created by Sascha Kratochvil on 18.11.23.
//

import Foundation
import XCTest

/// A wrapper around an accessibility button element.
///
/// Use this type when your test interacts with tappable controls such as
/// primary actions, confirmation buttons, or toolbar items.
///
/// ```swift
/// app.button("save")
///     .isExisting()
///     .isHittable()
///     .tap()
/// ```
public class SDKUITestButton: SDKUITestElement {
    override var typeName: String { "Button" }
}
