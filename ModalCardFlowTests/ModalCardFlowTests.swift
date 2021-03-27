//
//  ModalCardFlowTests.swift
//  ModalCardFlowTests
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import XCTest
@testable import ModalCardFlow

final class ModalCardFlowTests: XCTestCase {
    
    private var sut: ModalCardFlow<MockContext>!
    private var container = MockContainer()
    
    override func setUp() {
        super.setUp()
        let context = MockContext(someValue: nil)
        sut = ModalCardFlow<MockContext>(context: context, with: ModalCardConfig())
        sut.container = container
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func test_initialiseFlow_emptyStack_doesNotCrash() {
        XCTAssertNil(sut.currentCard)
    }
    
    func test_initialiseFlow_start_isCurrentCard() {
        let vc = MockViewController()
        sut.start(with: ParentCard(), andPresentOn: vc)
        XCTAssertTrue(vc.didPresentVC)
    }
    
    func test_showCurrentCard_hasCurrent() {
        sut.stack.append(ParentCard())
        sut.showCurrentCard(animationType: .fade(fadeIn: true))
        XCTAssertTrue(self.container.didAddCardToContainer)
    }
    
    func test_showCurrentCard_hasNoCurrent() {
        sut.showCurrentCard(animationType: .fade(fadeIn: true))
        XCTAssertFalse(container.didAddCardToContainer)
    }
    
    func test_dismissCurrentCard_hasCurrent() {
        let expectation = XCTestExpectation(description: "dismiss completion")
        sut.stack.append(ParentCard())
        sut.dismissCurrentCard(animationType: .fade(fadeIn: false)) {
            XCTAssertTrue(self.container.didAnimate)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }
    
    func test_dismissCurrentCard_hasNoCurrent() {
        let expectation = XCTestExpectation(description: "dismiss completion")
        sut.dismissCurrentCard(animationType: .fade(fadeIn: false)) {
            XCTAssertFalse(self.container.didAnimate)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }
    
    func test_finish() {
        sut.start(with: ParentCard(), andPresentOn: UIViewController())
        sut.closeFlow()
        XCTAssertTrue(self.sut.stack.isEmpty)
    }
    
    func test_childAction_updatesContext() {
        let child = ChildCard()
        sut.start(with: ParentCard(), andPresentOn: UIViewController())
        sut.push(card: child)
        child.doSomething()
        XCTAssertEqual(sut.context.someValue, "updated")
    }
    
    func test_pushChild_showsChild() {
        let child = ChildCard()
        sut.push(card: ParentCard())
        sut.push(card: child)
        XCTAssertTrue(sut.currentCard is ChildCard)
    }
    
    func test_popChild_showsParent() {
        let child = ChildCard()
        sut.push(card: ParentCard())
        sut.push(card: child)
        sut.pop()
        XCTAssertTrue(sut.currentCard is ParentCard)
    }
    
    func test_childUpdate_popToParent_parentUpdated() {
        let child = ChildCard()
        sut.push(card: ParentCard())
        sut.push(card: child)
        child.doSomething()
        sut.pop()
        XCTAssertEqual((sut.currentCard as? ParentCard)?.context?.someValue, "updated")
    }
}
