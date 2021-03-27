//
//  MockClasses.swift
//  ModalCardFlowTests
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit
@testable import ModalCardFlow

final class ParentCard: ModalCard<MockContext> { }

final class ChildCard: ModalCard<MockContext>, UITextFieldDelegate {

    var textField: UITextField?

    override func viewDidLoad() {
        textField = UITextField(frame: .zero)
        view.addSubview(textField ?? UITextField())
        textField?.delegate = self
    }

    func doSomething() {
        flow?.update(context: context?.update(someValue: "updated"))
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

final class MockContext: Context {

    var someValue: String?

    init(someValue: String?) {
        self.someValue = someValue
    }

    func update(someValue: String?) -> MockContext {
        return MockContext(someValue: someValue)
    }
}

final class MockContainer: UIViewController, ModalCardFlowContaining {

    var didAddCardToContainer: Bool = false
    var didAnimate: Bool = false
    weak var closingHandler: ModalCardFlowClosable?

    func addCardToContainer<C: Context>(card: ModalCard<C>) {
        didAddCardToContainer = true
    }

    func animate(type: ModalCardAnimationType, completion: (() -> Void)?) {
        didAnimate = true
        completion?()
    }
}

final class MockClosingHandler: ModalCardFlowClosable {

    var didCloseFlow: Bool = false

    func closeFlow() {
        didCloseFlow = true
    }
}

final class MockNotificationCenter: NotificationCenter {

    var didAddObserver: Bool = false
    var didRemoveObserver: Bool = false
    var observerAction: ((Notification) -> Void)?

    override func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        _ = super.addObserver(forName: name, object: obj, queue: queue, using: block)
        didAddObserver = true
        observerAction = block
        return self
    }

    override func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        super.removeObserver(observer, name: aName, object: anObject)
        observerAction = nil
        didRemoveObserver = true
    }
}

final class MockUIPanGestureRecognizer: UIPanGestureRecognizer {

    let target: Any?
    let action: Selector?
    var gestureState: UIGestureRecognizer.State?
    var gestureTranslation: CGPoint?

    override init(target: Any?, action: Selector?) {
        self.target = target
        self.action = action
        super.init(target: target, action: action)
    }

    override func translation(in view: UIView?) -> CGPoint {
        if let gestureTranslation = gestureTranslation {
            return gestureTranslation
        }
        return super.translation(in: view)
    }

    override var state: UIGestureRecognizer.State {
        get { gestureState ?? super.state }
        set { _ = newValue }
    }

    func pan(translation: CGPoint?, state: UIGestureRecognizer.State) {
        guard let action = action else { return }
        super.state = state
        gestureState = state
        gestureTranslation = translation
        (target as? NSObject)?.perform(action, on: .current, with: self, waitUntilDone: true)
    }
}

final class MockViewController: UIViewController {

    var didPresentVC: Bool = false

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        didPresentVC = true
    }
}
