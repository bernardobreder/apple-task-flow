//
//  TaskFlowTests.swift
//  TaskFlow
//
//  Created by Bernardo Breder.
//
//

import XCTest
@testable import TaskFlowTests

extension TaskFlowTests {

	static var allTests : [(String, (TaskFlowTests) -> () throws -> Void)] {
		return [
			("test", test),
		]
	}

}

XCTMain([
	testCase(TaskFlowTests.allTests),
])

