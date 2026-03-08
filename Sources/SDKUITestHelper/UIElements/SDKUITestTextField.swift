//
//  SDKUITestTextField.swift
//
//
//  Created by Sascha Kratochvil on 08.03.26.
//

import Foundation
import XCTest

/// A wrapper around text input fields.
///
/// Use this for regular and secure text fields when you need to type input in
/// a fluent assertion chain.
///
/// ```swift
/// app.secureTextField("login.token")
///     .isExisting()
///     .tap()
///     .typeText("token")
/// ```
public class SDKUITestTextField: SDKUITestElement {
    override var typeName: String { "TextField" }

    /// Types text into the field.
    ///
    /// - Parameter text: The text to type.
    /// - Returns: The same element wrapper for chaining.
    @discardableResult public func typeText(_ text: String) -> Self {
        element.typeText(text)
        return self
    }
}
