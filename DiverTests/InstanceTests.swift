//
//  InstanceTests.swift
//  DiverTests
//
//  Created by Gerald Burke on 11/5/24.
//

import XCTest

@testable import Diver

final class InstanceTests: XCTestCase {
    @MainActor func testItGetsInstances() throws {
        let repo = MockInstanceRepository()
        let subject = Instances(repo: repo)
        subject.getInstances()
        XCTAssertEqual(1, subject.available.count)
    }

    @MainActor func testItCanStoreInstance() throws {
        let repo = MockInstanceRepository()
        let subject = Instances(repo: repo)
        let instanceName = "https://sudonym.net"
        subject.add(instanceName)
        XCTAssertEqual(instanceName, subject.available.last?.domainName)
    }

    @MainActor func testItCanRemoveInstance() throws {
        let repo = MockInstanceRepository()
        let subject = Instances(repo: repo)
        subject.getInstances()
        let instance = try XCTUnwrap(subject.available.last)
        subject.remove(instance)
        XCTAssertTrue(subject.available.isEmpty)

    }
}
