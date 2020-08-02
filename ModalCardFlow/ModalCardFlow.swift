//
//  ModalCardFlow.swift
//  ModalCardFlow
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit

/// protocol Context: For the usage of applying context to the card
public protocol Context { }

open class ModalCardFlow<C: Context> {

    public typealias Card = ModalCard<C>

    weak var container: ModalCardFlowContaining?
    var stack: [Card] = []
    var context: C

    public init(context: C, with config: ModalCardConfig) {
        let container = ModalCardFlowContainer(notificationCenter: NotificationCenter.default, config: config)
        container.modalPresentationStyle = .overFullScreen
        container.loadViewIfNeeded()
        self.context = context
        self.container = container
        container.closingHandler = self
    }

    var currentCard: Card? {
        return stack.last
    }

    func showCurrentCard(animationType: ModalCardAnimationType) {
        guard let currentCard = currentCard else { return }
        currentCard.flow = self
        currentCard.context = context
        container?.addCardToContainer(card: currentCard)
        container?.animate(type: animationType, completion: nil)
    }

    func dismissCurrentCard(animationType: ModalCardAnimationType, completion: (() -> Void)?) {
        guard currentCard != nil else {
            completion?()
            return
        }
        container?.animate(type: animationType, completion: completion)
    }

    open func start(with card: Card, andPresentOn vc: UIViewController?) {
        guard let container = container as? UIViewController else { return }
        vc?.present(container, animated: false, completion: {
            self.stack.append(card)
            self.showCurrentCard(animationType: .slide(slideIn: true))
        })
    }

    open func finish(completion: (() -> Void)?) {
        container?.animate(type: .slide(slideIn: false)) {
            self.stack.removeAll()
            (self.container as? UIViewController)?.dismiss(animated: false, completion: {
                completion?()
            })
        }
    }

    open func push(card: Card) {
        dismissCurrentCard(animationType: .fade(fadeIn: false), completion: {
            self.stack.append(card)
            self.showCurrentCard(animationType: .fade(fadeIn: true))
        })
    }

    open func pop() {
        dismissCurrentCard(animationType: .fade(fadeIn: false), completion: {
            self.stack.removeLast()
            self.showCurrentCard(animationType: .fade(fadeIn: true))
        })
    }

    open func update(context: C?) {
        guard let context = context else { return }
        self.context = context
    }
}

extension ModalCardFlow: ModalCardFlowClosable {
    func closeFlow() {
        finish(completion: nil)
    }
}
