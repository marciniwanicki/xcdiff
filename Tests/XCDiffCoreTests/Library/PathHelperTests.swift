//
// Copyright 2021 Bloomberg Finance L.P.
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
import XCTest
import XcodeProj
import PathKit
@testable import XCDiffCore

final class PathHelperTests: XCTestCase {
    func testFullPath_whenCannotDetermineFullPathError() {
        // Given
        let subject = PathHelper()
        let fileElement = PBXFileElement(sourceTree: .group, path: "test/path")
        let sourceRoot = Path("/project/test-project")

        // When / Then
        XCTAssertThrowsError(try subject.fullPath(from: fileElement, sourceRoot: sourceRoot)) { error in
            XCTAssertTrue(error.localizedDescription.starts(with: "Determining full path to \"test/path\" failed."),
                          "Unexpected error message: \(error.localizedDescription)")
       }
    }

    func testFullPath_whenPBXFileElementIsNil() throws {
        // Given
        let subject = PathHelper()
        let sourceRoot = Path("/project/test-project")

        // When
        let fullPath = try subject.fullPath(from: nil, sourceRoot: sourceRoot)

        // Then
        XCTAssertNil(fullPath)
    }

    func testFullPath_whenAbsolutePath() throws {
        // Given
        let subject = PathHelper()
        let sourceRoot = Path("/project/test-project")
        let fileElement = PBXFileElement(sourceTree: .absolute, path: "/absolute/path")

        // When
        let fullPath = try subject.fullPath(from: fileElement, sourceRoot: sourceRoot)

        // Then
        XCTAssertEqual(fullPath, "../../absolute/path")
    }
}
