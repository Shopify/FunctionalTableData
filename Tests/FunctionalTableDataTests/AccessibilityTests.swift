//
//  AccessibilityTests.swift
//  FunctionalTableDataTests
//
//  Created by Geoffrey Foster on 2020-05-12.
//  Copyright © 2020 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class AccessibilityTests: XCTestCase {
	
	func testAccessibilityIdentifier() {
		XCTAssertEqual(Accessibility().with(defaultIdentifier: "success").identifier, "success")
		XCTAssertEqual(Accessibility(identifier: "success").with(defaultIdentifier: "fail").identifier, "success")
	}
	
}
