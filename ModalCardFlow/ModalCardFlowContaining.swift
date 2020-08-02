//
//  ModalCardFlowContaining.swift
//  ModalCardFlow
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import Foundation

protocol ModalCardFlowContaining: class {
    func addCardToContainer<C: Context>(card: ModalCard<C>)
    func animate(type: ModalCardAnimationType, completion: (() -> Void)?)

    var closingHandler: ModalCardFlowClosable? { get set }
}

protocol ModalCardFlowClosable: class {
    func closeFlow()
}
