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
import XcodeProj

class PathHelper {
    func fullPath(from fileElement: PBXFileElement?, sourceRoot: Path) throws -> String? {
        do {
            guard let path = try fileElement?.fullPath(sourceRoot: sourceRoot.absolute()) else {
                return nil
            }
            guard path.isAbsolute else {
                return path.string
            }
            return path.url.relative(to: sourceRoot.absolute().url)
        } catch let error as CustomStringConvertible {
            if let fileElement = fileElement, let pathOrName = fileElement.path ?? fileElement.name {
                throw XCDiffCoreError.generic("""
                Determining full path to "\(pathOrName)" failed. \(error.description)
                """)
            } else {
                throw XCDiffCoreError.generic(error.description)
            }
        }
    }
}
