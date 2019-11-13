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

public struct ComparatorType {
    public static let fileReferences: ComparatorType = .init(FileReferencesComparator())
    public static let targets: ComparatorType = .init(TargetsComparator())
    public static let headers: ComparatorType = .init(HeadersComparator())
    public static let sources: ComparatorType = .init(SourcesComparator())
    public static let resources: ComparatorType = .init(ResourcesComparator())
    public static let configurations: ComparatorType = .init(ConfigurationsComparator())
    public static let settings: ComparatorType = .init(SettingsComparator())
    public static let resolvedSettings: ComparatorType = .init(ResolvedSettingsComparator(system: DefaultSystem()))
    public static let sourceTrees: ComparatorType = .init(SourceTreesComparator())
    public static let dependencies: ComparatorType = .init(DependenciesComparator())

    public let tag: ComparatorTag
    private let comparatorOrFactory: Either<Comparator, () -> Comparator>

    public init(_ factory: @escaping () -> Comparator) {
        comparatorOrFactory = .right(factory)
        tag = factory().tag
    }

    public init(_ comparator: Comparator) {
        comparatorOrFactory = .left(comparator)
        tag = comparator.tag
    }

    @available(*, deprecated, message: "Please use `init(_:)` instead")
    public static func custom(_ comparator: Comparator) -> ComparatorType {
        return ComparatorType(comparator)
    }

    func comparator() -> Comparator {
        switch comparatorOrFactory {
        case let .left(comparator):
            return comparator
        case let .right(factory):
            return factory()
        }
    }
}

public extension Array where Element == ComparatorType {
    static var allAvailableComparators: [ComparatorType] {
        return [
            .fileReferences,
            .targets,
            .headers,
            .sources,
            .resources,
            .configurations,
            .settings,
            .resolvedSettings,
            .sourceTrees,
            .dependencies,
        ]
    }

    static var defaultComparators: [ComparatorType] {
        return [
            .fileReferences,
            .targets,
            .headers,
            .sources,
            .resources,
            .configurations,
            .settings,
            .sourceTrees,
            .dependencies,
        ]
    }
}
