//
//  SDKUITestLabel.swift
//
//
//  Created by Sascha Kratochvil on 18.11.23.
//

import Foundation
import XCTest

/// A wrapper around a static text label element.
///
/// Labels are typically used for content verification rather than interaction,
/// for example status text, titles, or validation messages.
///
/// ```swift
/// app.label("status-title")
///     .isExisting()
///     .validate(title: "Completed")
/// ```
public class SDKUITestLabel: SDKUITestElement {
    override var typeName: String { "Label" }
}
