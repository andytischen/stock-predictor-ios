import Foundation

/// A published edition of Randy's Global News First: the stories on offer plus
/// when the edition was cut. Decoded from the same style of snake_case JSON the
/// other feeds in this repo use.
public struct Edition: Codable, Equatable, Sendable {
    public let generatedAt: String
    public let headline: String
    public let stories: [Story]

    public init(generatedAt: String, headline: String, stories: [Story]) {
        self.generatedAt = generatedAt
        self.headline = headline
        self.stories = stories
    }

    /// Parsed edition time, if the string is a valid ISO-8601 instant.
    public var generatedDate: Date? { Edition.iso8601.date(from: generatedAt) }

    /// The story to run above the fold: the first lead, else the first story.
    public var lead: Story? { stories.first(where: \.isLead) ?? stories.first }

    /// Everything except ``lead``, in publication order.
    public var rest: [Story] {
        guard let lead else { return [] }
        return stories.filter { $0.id != lead.id }
    }

    /// The regions present, in the order they first appear.
    public var regions: [Region] {
        var seen: [Region] = []
        for story in stories where !seen.contains(story.region) {
            seen.append(story.region)
        }
        return seen
    }

    public func stories(in region: Region) -> [Story] {
        stories.filter { $0.region == region }
    }

    enum CodingKeys: String, CodingKey {
        case generatedAt = "generated_at"
        case headline
        case stories
    }

    public static var decoder: JSONDecoder { JSONDecoder() }

    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

/// One story in an edition.
public struct Story: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let headline: String
    public let standfirst: String
    public let body: String
    public let region: Region
    public let topic: Topic
    public let source: String
    public let publishedAt: String
    public let imageURL: URL?
    public let articleURL: URL?
    public let isLead: Bool
    public let isBreaking: Bool

    public init(
        id: String, headline: String, standfirst: String, body: String, region: Region,
        topic: Topic, source: String, publishedAt: String, imageURL: URL? = nil,
        articleURL: URL? = nil, isLead: Bool = false, isBreaking: Bool = false
    ) {
        self.id = id
        self.headline = headline
        self.standfirst = standfirst
        self.body = body
        self.region = region
        self.topic = topic
        self.source = source
        self.publishedAt = publishedAt
        self.imageURL = imageURL
        self.articleURL = articleURL
        self.isLead = isLead
        self.isBreaking = isBreaking
    }

    /// Parsed publication time, if the string is a valid ISO-8601 instant.
    public var publishedDate: Date? { Edition.iso8601.date(from: publishedAt) }

    /// Paragraphs of ``body``, for laying the article out with real spacing.
    public var paragraphs: [String] {
        body.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case headline
        case standfirst
        case body
        case region
        case topic
        case source
        case publishedAt = "published_at"
        case imageURL = "image_url"
        case articleURL = "article_url"
        case isLead = "is_lead"
        case isBreaking = "is_breaking"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        headline = try container.decode(String.self, forKey: .headline)
        standfirst = try container.decodeIfPresent(String.self, forKey: .standfirst) ?? ""
        body = try container.decodeIfPresent(String.self, forKey: .body) ?? ""
        region = try container.decode(Region.self, forKey: .region)
        topic = try container.decodeIfPresent(Topic.self, forKey: .topic) ?? .world
        source = try container.decodeIfPresent(String.self, forKey: .source) ?? ""
        publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt) ?? ""
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        articleURL = try container.decodeIfPresent(URL.self, forKey: .articleURL)
        isLead = try container.decodeIfPresent(Bool.self, forKey: .isLead) ?? false
        isBreaking = try container.decodeIfPresent(Bool.self, forKey: .isBreaking) ?? false
    }
}

/// The desks the app files stories under. Unknown values decode to ``other``
/// so a new desk in the feed never breaks an installed build.
public enum Region: String, Codable, CaseIterable, Equatable, Sendable {
    case africa
    case americas
    case asiaPacific = "asia_pacific"
    case europe
    case middleEast = "middle_east"
    case other

    public var title: String {
        switch self {
        case .africa: return "Africa"
        case .americas: return "Americas"
        case .asiaPacific: return "Asia-Pacific"
        case .europe: return "Europe"
        case .middleEast: return "Middle East"
        case .other: return "Elsewhere"
        }
    }

    /// SF Symbol used on tabs and section headers.
    public var symbolName: String {
        switch self {
        case .africa: return "globe.europe.africa.fill"
        case .americas: return "globe.americas"
        case .asiaPacific: return "globe.asia.australia"
        case .europe: return "globe.europe.africa"
        case .middleEast: return "globe.central.south.asia"
        case .other: return "globe"
        }
    }

    public init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Region(rawValue: raw) ?? .other
    }
}

/// A story's beat, shown as a kicker above the headline.
public enum Topic: String, Codable, CaseIterable, Equatable, Sendable {
    case world
    case business
    case markets
    case politics
    case technology
    case energy
    case sport
    case culture

    public var title: String {
        switch self {
        case .world: return "World"
        case .business: return "Business"
        case .markets: return "Markets"
        case .politics: return "Politics"
        case .technology: return "Technology"
        case .energy: return "Energy"
        case .sport: return "Sport"
        case .culture: return "Culture"
        }
    }

    public init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Topic(rawValue: raw) ?? .world
    }
}
