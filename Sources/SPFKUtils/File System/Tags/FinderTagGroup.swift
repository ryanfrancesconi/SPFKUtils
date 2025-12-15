// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import Foundation

    /// Describes the tags found and set by the finder such as colored labels
    public struct FinderTagGroup: Hashable, Sendable {
        public static let defaultTags: FinderTagGroup = .init(
            tags: Set(
                TagColor.allCases.map {
                    FinderTagDescription(tagColor: $0)
                }
            )
        )

        // codable
        public var tags: Set<FinderTagDescription> = .init()

        public var stringValue: String {
            tags.map(\.label)
                .sorted()
                .joined(separator: ", ")
        }

        public var defaultColor: NSColor? {
            guard let first = tags.first(where: { tag in
                tag.tagColor != .none
            }) else { return nil }

            guard let nsColor = first.tagColor.nsColor else {
                return nil
            }

            return nsColor
        }

        public func tagColors() -> [TagColor] {
            tags.filter {
                $0.tagColor != .none
            }
            .map(\.tagColor)
        }

        public init() {}

        public init(url: URL) {
            self = FinderTagGroup(tags: url.finderTags)
        }

        public init(tags: Set<FinderTagDescription>) {
            self.tags = tags
        }

        public mutating func insert(colors: Set<FinderTagDescription>) {
            tags = tags.filter { $0.tagColor == .none }
            let colors = colors.filter { $0.tagColor != .none }

            tags = tags.union(colors)
        }
    }

    extension FinderTagGroup: Codable {
        enum CodingKeys: String, CodingKey {
            case tags
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            tags = try container.decode(Set<FinderTagDescription>.self, forKey: .tags)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(tags, forKey: .tags)
        }
    }

#endif
