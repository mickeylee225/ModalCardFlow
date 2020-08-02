//
//  ModalCardFlowContainer.swift
//  ModalCardFlow
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit

class ModalCardFlowContainer: UIViewController, ModalCardFlowContaining {

    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    weak var closingHandler: ModalCardFlowClosable?

    private var config: ModalCardConfig?
    private var notificationCenter: NotificationCenter?

    private var _initialTouchPoint: CGPoint = .zero
    private var _initialContainerFrame: CGRect = .zero
    private var _isKeyboardShowing: Bool = false

    var initialTouchPoint: CGPoint { _initialTouchPoint }
    var initialContainerFrame: CGRect { _initialContainerFrame }
    var isKeyboardShowing: Bool { _isKeyboardShowing }

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
        guard !_isKeyboardShowing else { return }
        let touchPoint = sender.location(in: view?.window)
        switch sender.state {
        case .began:
            _initialTouchPoint = touchPoint
            _initialContainerFrame = container.frame
        case .changed:
            if touchPoint.y - _initialTouchPoint.y > 0 {
                container.frame = CGRect(x: container.frame.origin.x, y: touchPoint.y, width: container.frame.width, height: container.frame.height)
            }
        case .ended, .cancelled:
            if (touchPoint.y - _initialTouchPoint.y) > (container.frame.height / 2) {
                dismissContainer()
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.container.frame = self.initialContainerFrame
                })
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
            self?._isKeyboardShowing = true
            self?.updateCardView(keyboardHeight: keyboardSize.cgRectValue.height, duration: duration.doubleValue)
        }
        _ = notificationCenter?.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
            self?._isKeyboardShowing = false
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
            let prevFrame = container.frame
            let prevAlpha: CGFloat = slideIn ? 0 : 1
            dimView.alpha = prevAlpha
            container.frame.origin.y = slideIn ? prevFrame.origin.y + container.frame.height : prevFrame.origin.y
            UIView.animate(withDuration: 0.4, animations: {
                self.dimView.alpha = slideIn ? 1 : 0
                self.container.frame.origin.y = slideIn ? prevFrame.origin.y : prevFrame.origin.y + self.container.frame.height
            }, completion: { _ in
                completion?()
            })
        }
    }

    @objc func dismissContainer() {
        closingHandler?.closeFlow()
    }
}
