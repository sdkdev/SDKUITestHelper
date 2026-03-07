//
//  SDKUITestLink.swift
//
//
//  Created by Mohamed on 02.04.24.
//

import Foundation
import XCTest

/// A wrapper around a tappable link element.
///
/// Use this type for deep links, legal links, or inline action links exposed
/// through accessibility.
///
/// ```swift
/// app.link("privacy-policy")
///     .isExisting()
///     .isHittable()
///     .tap()
/// ```
public class SDKUITestLink: SDKUITestElement {
    override var typeName: String { "Link" }
}
