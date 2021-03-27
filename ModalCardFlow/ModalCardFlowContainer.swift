//
//  ModalCardFlowContainer.swift
//  ModalCardFlow
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit

final class ModalCardFlowContainer: UIViewController, ModalCardFlowContaining {

    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    weak var closingHandler: ModalCardFlowClosable?

    private var config: ModalCardConfig?
    private var notificationCenter: NotificationCenter?

    private(set) var initialTranslation: CGPoint = .zero
    private(set) var initialContainerCenter: CGPoint = .zero
    private(set) var isKeyboardShowing: Bool = false

    convenience init(notificationCenter: NotificationCenter, config: ModalCardConfig) {
        self.init(nibName: String(describing: ModalCardFlowContainer.self), bundle: Bundle(identifier: "com.mickeylee.ModalCardFlow"))
        self.notificationCenter = notificationCenter
        self.config = config
        addKeyboardObservers()
    }

    deinit {
        removeKeyboardObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupGestures()
    }

    // MARK: - Setup View & Gesture

    private func setupView() {
        guard let config = config else { return }
        dimView.backgroundColor = config.dimViewColour?.withAlphaComponent(config.dimViewAlpha)
        container.layer.cornerRadius = config.containerRadius
        container.backgroundColor = config.containerColour
        titleLabel.text = config.title
        titleLabel.font = config.titleFont
    }

    private func setupGestures() {
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissContainer)))
        guard let config = config, config.dragToDismissEnabled else { return }
        container.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }

    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: container)
        guard !isKeyboardShowing, translation.y > initialTranslation.y else { return }
        switch sender.state {
        case .began:
            initialTranslation = translation
            initialContainerCenter = container.center
            container.translatesAutoresizingMaskIntoConstraints = true
        case .changed:
            container.center = CGPoint(x: initialContainerCenter.x, y: initialContainerCenter.y + translation.y)
        case .ended, .cancelled:
            // Moving downward from the start point more than 100 closes the flow
            if translation.y - initialTranslation.y > 100 {
                dismissContainer()
            } else {
                container.center = initialContainerCenter
            }
        default:
            break
        }
    }

    // MARK: - Keyboard Observers

    private func addKeyboardObservers() {
        _ = notificationCenter?.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            guard
                let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
                else {
                    return
            }
            self?.isKeyboardShowing = true
            self?.updateCardView(keyboardHeight: keyboardSize.cgRectValue.height, duration: duration.doubleValue)
        }
        _ = notificationCenter?.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
            self?.isKeyboardShowing = false
            self?.updateCardView(keyboardHeight: nil, duration: duration.doubleValue)
        }
    }

    private func removeKeyboardObservers() {
        notificationCenter?.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter?.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func updateCardView(keyboardHeight: CGFloat?, duration: Double) {
        UIView.animate(withDuration: duration, delay: TimeInterval(0), options: .curveEaseIn, animations: {
            self.view.transform = keyboardHeight != nil ? .init(translationX: 0, y: -(keyboardHeight ?? CGFloat(0))) : .identity
        })
    }

    // MARK: - Internal Methods

    func addCardToContainer<C: Context>(card: ModalCard<C>) {
        guard let cardView = card.view else { return }
        for subview in cardContainer.subviews {
            subview.removeFromSuperview()
        }
        for child in children {
            child.removeFromParent()
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(cardView)
        addChild(card)
        card.applyContext()
        let margins = cardContainer.layoutMarginsGuide
        cardView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        cardView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        cardView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        cardView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }

    func animate(type: ModalCardAnimationType, completion: (() -> Void)?) {
        view.layoutSubviews()
        switch type {
        case .fade(let fadeIn):
            let prevAlpha: CGFloat = fadeIn ? 0 : 1
            cardContainer.alpha = prevAlpha
            UIView.animate(withDuration: 0.4, animations: {
                self.cardContainer.alpha = fadeIn ? 1 : 0
            }, completion: { _ in
                completion?()
            })
        case .slide(let slideIn):
            if slideIn {
                let prevFrame = container.frame
                dimView.alpha = 0
                container.frame.origin.y += container.frame.height
                UIView.animate(withDuration: 0.4, animations: {
                    self.dimView.alpha = 1
                    self.container.frame.origin.y = prevFrame.origin.y
                }, completion: { _ in
                    completion?()
                })
            } else {
                dimView.alpha = 1
                container.translatesAutoresizingMaskIntoConstraints = true
                UIView.animate(withDuration: 0.4, animations: {
                    self.dimView.alpha = 0
                    self.container.center.y += self.container.frame.height
                }, completion: { _ in
                    completion?()
                })
            }
        }
    }

    @objc func dismissContainer() {
        closingHandler?.closeFlow()
    }
}
