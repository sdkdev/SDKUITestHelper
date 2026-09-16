//
//  SDKUIElement.swift
//
//
//  Created by Sascha Kratochvil on 18.11.23.
//

import Foundation
import XCTest

@MainActor
protocol SDKUIElement {
    func validate(title: String) -> Self
    func validate(isEnabled: Bool) -> Self
    func tap() -> Self
    func universalClick() -> Self
}
