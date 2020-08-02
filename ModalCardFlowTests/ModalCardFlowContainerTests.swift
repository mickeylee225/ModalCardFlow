//
//  ModalCardFlowContainerTests.swift
//  ModalCardFlowTests
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import XCTest
@testable import ModalCardFlow

class ModalCardFlowContainerTests: XCTestCase {

    var sut: ModalCardFlowContainer!
    var initialContainerFrame: CGRect = .zero

    override func setUp() {
        super.setUp()
        sut = ModalCardFlowContainer(notificationCenter: NotificationCenter.default, config: ModalCardConfig())
        sut.loadViewIfNeeded()
        initialContainerFrame = sut.container.frame
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        initialContainerFrame = .zero
    }

    func test_setupView() {
        let config = ModalCardConfig(title: "Test")
        let sut = ModalCardFlowContainer(notificationCenter: NotificationCenter.default, config: config)
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.titleLabel.text, "Test")
    }

    func test_setupGestures_dragToDismissEnabled() {
        let dimViewGestures = sut.dimView.gestureRecognizers ?? []
        XCTAssertTrue(dimViewGestures.contains(where: { $0 is UITapGestureRecognizer }))
        let containerGestures = sut.container.gestureRecognizers ?? []
        XCTAssertTrue(containerGestures.contains(where: { $0 is UIPanGestureRecognizer }))
    }

    func test_setupGestures_dragToDismissDisabled() {
        let config = ModalCardConfig(dragToDismissEnabled: false)
        let sut = ModalCardFlowContainer(notificationCenter: NotificationCenter.default, config: config)
        sut.loadViewIfNeeded()
        let containerGestures = sut.container.gestureRecognizers ?? []
        XCTAssertFalse(containerGestures.contains(where: { $0 is UIPanGestureRecognizer }))
    }

    func test_handleDismiss() {
        let mockPanGesture = MockUIPanGestureRecognizer(target: sut, action: #selector(sut.handleDismiss))
        sut.container.addGestureRecognizer(mockPanGesture)
        mockPanGesture.pan(location: CGPoint(x: 100, y: 100), state: .began)
        XCTAssertEqual(sut.initialTouchPoint, CGPoint(x: 100, y: 100))
        mockPanGesture.pan(location: CGPoint(x: 100, y: 200), state: .changed)
        XCTAssertEqual(sut.container.frame.origin.y, CGFloat(200))
        mockPanGesture.pan(location: CGPoint(x: 100, y: 150), state: .ended)
        XCTAssertEqual(sut.container.frame, sut.initialContainerFrame)
        let mockDelegate = MockClosingHandler()
        sut.closingHandler = mockDelegate
        mockPanGesture.pan(location: CGPoint(x: 100, y: 300), state: .ended)
        XCTAssertTrue(mockDelegate.didCloseFlow)
    }

    func test_addKeyboardObservers() {
        let notification = MockNotificationCenter()
        _ = ModalCardFlowContainer(notificationCenter: notification, config: ModalCardConfig())
        XCTAssertTrue(notification.didAddObserver)
    }

    func test_keyboardObservers() {
        let notification = MockNotificationCenter()
        let sut = ModalCardFlowContainer(notificationCenter: notification, config: ModalCardConfig())
        var userInfo: [AnyHashable: Any] = [UIResponder.keyboardFrameEndUserInfoKey: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)) as NSValue, UIResponder.keyboardAnimationDurationUserInfoKey: 0.4 as NSNumber]
        notification.post(name: UIResponder.keyboardWillShowNotification, object: nil, userInfo: userInfo)
        XCTAssertNotNil(notification.observerAction)
        XCTAssertTrue(sut.isKeyboardShowing)
        userInfo = [UIResponder.keyboardAnimationDurationUserInfoKey: 0.4 as NSNumber]
        notification.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: userInfo)
        XCTAssertFalse(sut.isKeyboardShowing)
    }

    func test_present_containsView() {
        let parentCard = ParentCard()
        parentCard.view = UIView()
        sut.addCardToContainer(card: parentCard)
        guard let parentCardView = parentCard.view else { return XCTFail("Missing parentCardView") }
        XCTAssertTrue(sut.cardContainer.subviews.contains(parentCardView))
    }

    func test_animate_fadeIn() {
        let expectation = XCTestExpectation(description: "did animate")
        sut.animate(type: .fade(fadeIn: true)) {
            XCTAssertEqual(self.sut.cardContainer.alpha, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }

    func test_animate_fadeOut() {
        let expectation = XCTestExpectation(description: "did animate")
        sut.animate(type: .fade(fadeIn: false)) {
            XCTAssertEqual(self.sut.cardContainer.alpha, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }

    func test_animate_slideIn() {
        let expectation = XCTestExpectation(description: "did animate")
        sut.view.layoutSubviews()
        initialContainerFrame = sut.container.frame
        sut.animate(type: .slide(slideIn: true)) {
            XCTAssertEqual(self.sut.container.frame, self.initialContainerFrame)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }

    func test_animate_slideOut() {
        let expectation = XCTestExpectation(description: "did animate")
        sut.animate(type: .slide(slideIn: false)) {
            XCTAssertNotEqual(self.sut.container.frame, self.initialContainerFrame)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }

    func test_dismissContainer() {
        let mockDelegate = MockClosingHandler()
        sut.closingHandler = mockDelegate
        sut.dismissContainer()
        XCTAssertTrue(mockDelegate.didCloseFlow)
    }
}
