//
//  ModalCardTests.swift
//  ModalCardFlowTests
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import XCTest
@testable import ModalCardFlow


class ModalCardTests: XCTestCase {

    func test_initialiseCard_emptyVariables() {
        let sut = ParentCard()
        XCTAssertNil(sut.flow)
        XCTAssertNil(sut.context)
    }
}
