//
// Copyright 2019 Bloomberg Finance L.P.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import PathKit
@testable import XCDiffCore
import XCTest

final class DefaultProjectComparatorTests: XCTestCase {
    private let firstPath = Path("/first.xcodeproj")
    private let secondPath = Path("/second.xcodeproj")
    private let parametersAll = ComparatorParameters(targets: .all, configurations: .all)

    func testCompare_whenNoComparators_success() throws {
        // Given
        let subject = DefaultProjectComparator(comparators: [],
                                               resultRenderer: UniversalResultRenderer(format: .console, verbose: true),
                                               xcodeProjLoader: XcodeProjLoaderMock(),
                                               differencesOnly: false,
                                               continueAfterError: false)

        // When
        let result = try subject.compare(firstPath, secondPath, parameters: parametersAll)

        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.output, "")
    }

    func testCompare_whenCustomComparatorAndNoResults_success() throws {
        // Given
        let comparator = ComparatorMock(tag: "Comparator1") { _, _, _ in [] }
        let comparators: [XCDiffCore.Comparator] = [comparator]
        let subject = DefaultProjectComparator(comparators: comparators,
                                               resultRenderer: UniversalResultRenderer(format: .console, verbose: true),
                                               xcodeProjLoader: XcodeProjLoaderMock(),
                                               differencesOnly: false,
                                               continueAfterError: false)

        // When
        let result = try subject.compare(firstPath, secondPath, parameters: parametersAll)

        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.output, "")
    }

    func testCompare_whenCustomComparatorAndNoDifference_success() throws {
        // Given
        let tag = "Comparator1"
        let comparator = ComparatorMock(tag: tag) { _, _, _ in [CompareResult(tag: tag)] }
        let comparators: [XCDiffCore.Comparator] = [comparator]
        let subject = DefaultProjectComparator(comparators: comparators,
                                               resultRenderer: UniversalResultRenderer(format: .console, verbose: true),
                                               xcodeProjLoader: XcodeProjLoaderMock(),
                                               differencesOnly: false,
                                               continueAfterError: false)

        // When
        let result = try subject.compare(firstPath, secondPath, parameters: parametersAll)

        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.output, "✅ COMPARATOR1\n")
    }

    func testCompare_whenDifferencesOnlyCustomComparatorAndNoDifference_emptyOutput() throws {
        // Given
        let tag = "Comparator1"
        let comparator = ComparatorMock(tag: tag) { _, _, _ in [CompareResult(tag: tag)] }
        let comparators: [XCDiffCore.Comparator] = [comparator]
        let subject = DefaultProjectComparator(comparators: comparators,
                                               resultRenderer: UniversalResultRenderer(format: .console, verbose: true),
                                               xcodeProjLoader: XcodeProjLoaderMock(),
                                               differencesOnly: true,
                                               continueAfterError: false)

        // When
        let result = try subject.compare(firstPath, secondPath, parameters: parametersAll)

        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.output, "")
    }

    func testCompare_whenCustomComparatorAndSomeDifferences_error() throws {
        // Given
        let tag = "Comparator1"
        let comparator = ComparatorMock(tag: tag) { _, _, _ in [CompareResult(tag: tag, onlyInFirst: ["file.txt"])] }
        let comparators: [XCDiffCore.Comparator] = [comparator]
        let subject = DefaultProjectComparator(comparators: comparators,
                                               resultRenderer: UniversalResultRenderer(format: .console, verbose: true),
                                               xcodeProjLoader: XcodeProjLoaderMock(),
                                               differencesOnly: false,
                                               continueAfterError: false)

        // When
        let result = try subject.compare(firstPath, secondPath, parameters: parametersAll)

        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.output, """
        ❌ COMPARATOR1

        ⚠️  Only in first (1):

          • file.txt\n\n

        """)
    }

    func testCompare_whenDifferencesOnlyCustomComparatorAndSomeDifferences_error() throws {
        // Given
        let tag = "Comparator1"
        let comparator = ComparatorMock(tag: tag) { _, _, _ in [CompareResult(tag: tag, onlyInFirst: ["file.txt"])] }
        let comparators: [XCDiffCore.Comparator] = [comparator]
        let subject = DefaultProjectComparator(comparators: comparators,
                                               resultRenderer: UniversalResultRenderer(format: .console, verbose: true),
                                               xcodeProjLoader: XcodeProjLoaderMock(),
                                               differencesOnly: true,
                                               continueAfterError: false)

        // When
        let result = try subject.compare(firstPath, secondPath, parameters: parametersAll)

        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.output, """
        ❌ COMPARATOR1

        ⚠️  Only in first (1):

          • file.txt\n\n

        """)
    }

    func testCompare_whenResultErrorReturnedAndContinueAfterErrorFalse_error() throws {
        // Given
        let tag = "Comparator1"
        let comparator = ComparatorMock(tag: tag) { _, _, _ in
            [
                CompareResult(tag: tag, onlyInFirst: ["file.txt"]),
                .error(.init(tag: tag, errors: [.generic("Test error1"), .generic("Test error2")]))
            ]
        }
        let comparators: [XCDiffCore.Comparator] = [comparator]
        let subject = DefaultProjectComparator(comparators: comparators,
                                               resultRenderer: UniversalResultRenderer(format: .console, verbose: true),
                                               xcodeProjLoader: XcodeProjLoaderMock(),
                                               differencesOnly: true,
                                               continueAfterError: false)

        // When / Then
        XCTAssertThrowsError(try subject.compare(firstPath, secondPath, parameters: parametersAll)) { error in
            XCTAssertEqual(error.localizedDescription, "Test error1")
        }
    }
}
