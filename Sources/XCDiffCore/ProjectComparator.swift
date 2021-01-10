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

public enum Format: String, RawRepresentable, CaseIterable {
    case console
    case markdown
    case json
    case html
}

public struct Mode {
    public static let `default` = Mode()

    public let format: Format
    public let verbose: Bool
    public let differencesOnly: Bool
    public let continueAfterError: Bool

    public init(format: Format = .console,
                verbose: Bool = false,
                differencesOnly: Bool = false,
                continueAfterError: Bool = false) {
        self.format = format
        self.verbose = verbose
        self.differencesOnly = differencesOnly
        self.continueAfterError = continueAfterError
    }
}

public struct Result {
    public let success: Bool
    public let output: String
}

public protocol ProjectComparator {
    func compare(_ firstPath: Path,
                 _ secondPath: Path,
                 parameters: ComparatorParameters) throws -> Result
}

public enum ProjectComparatorFactory {
    public static func create(comparators: [ComparatorType] = .allAvailableComparators,
                              mode: Mode = .default) -> ProjectComparator {
        let resultRenderer = UniversalResultRenderer(format: mode.format,
                                                     verbose: mode.verbose)
        let xcodeProjLoader = DefaultXcodeProjLoader()
        return DefaultProjectComparator(comparators: comparators.map { $0.comparator() },
                                        resultRenderer: resultRenderer,
                                        xcodeProjLoader: xcodeProjLoader,
                                        differencesOnly: mode.differencesOnly,
                                        continueAfterError: mode.continueAfterError)
    }
}

final class DefaultProjectComparator: ProjectComparator {
    private let comparators: [Comparator]
    private let resultRenderer: ResultRenderer
    private let xcodeProjLoader: XcodeProjLoader
    private let differencesOnly: Bool
    private let continueAfterError: Bool

    // MARK: - Lifecycle

    init(comparators: [Comparator],
         resultRenderer: ResultRenderer,
         xcodeProjLoader: XcodeProjLoader,
         differencesOnly: Bool,
         continueAfterError: Bool) {
        self.comparators = comparators
        self.resultRenderer = resultRenderer
        self.xcodeProjLoader = xcodeProjLoader
        self.differencesOnly = differencesOnly
        self.continueAfterError = continueAfterError
    }

    // MARK: - ProjectComparator

    func compare(_ firstPath: Path,
                 _ secondPath: Path,
                 parameters: ComparatorParameters) throws -> Result {
        let xcodeProj1 = try createProjectDescriptor(with: firstPath)
        let xcodeProj2 = try createProjectDescriptor(with: secondPath)
        let result = try compare(xcodeProj1, xcodeProj2, parameters: parameters)
        let success = result.same()
        let output = try resultRenderer.render(result)
        return Result(success: success, output: output)
    }

    // MARK: - Private

    private func compare(_ first: ProjectDescriptor,
                         _ second: ProjectDescriptor,
                         parameters: ComparatorParameters) throws -> ProjectCompareResult {
        let results = try comparators
            .flatMap { comparator -> [CompareResult] in
                let result = comparator.compare(first: first, second: second, parameters: parameters)
                if !continueAfterError {
                    try result.forEach {
                        if case let .error(compareError) = $0, let error = compareError.errors.first {
                            throw error
                        }
                    }
                }
                return result
            }
            .filter { !differencesOnly || !$0.same() }
        return ProjectCompareResult(first: first, second: second, results: results)
    }

    private func createProjectDescriptor(with path: Path) throws -> ProjectDescriptor {
        let xcodeProj = try xcodeProjLoader.load(at: path)
        return ProjectDescriptor(path: path, xcodeProj: xcodeProj)
    }
}

private extension Comparator {
    func compare(first: ProjectDescriptor,
                 second: ProjectDescriptor,
                 parameters: ComparatorParameters) -> [CompareResult] {
        do {
            return try compare(first, second, parameters: parameters)
        } catch let error as XCDiffCoreError {
            return [.error(.init(tag: tag,
                                 context: [],
                                 errors: [error]))]
        } catch {
            return [.error(.init(tag: tag,
                                 context: [],
                                 errors: [.generic(error.localizedDescription)]))]
        }
    }
}
