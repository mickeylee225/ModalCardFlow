//
//  ExampleContext.swift
//  ModalCardFlowExample
//
//  Created by Mickey Lee on 03/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import Foundation
import ModalCardFlow

final class ExampleContext: Context {

    var quantity: Int?

    init(quantity: Int? = nil) {
        self.quantity = quantity
    }

    func update(quantity: Int?) -> ExampleContext {
        return ExampleContext(quantity: quantity)
    }
}
