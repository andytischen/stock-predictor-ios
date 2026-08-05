import Foundation

/// The daily forecast snapshot published by `gapmodel export` and consumed by
/// the app. Decode it with ``Snapshot/decoder`` (snake_case → camelCase).
public struct Snapshot: Codable, Equatable, Sendable {
    public let generatedAt: String
    public let summary: String
    public let markets: [Market]
    public let crude: [Crude]

    public init(generatedAt: String, summary: String, markets: [Market], crude: [Crude]) {
        self.generatedAt = generatedAt
        self.summary = summary
        self.markets = markets
        self.crude = crude
    }

    /// Parsed generation time, if the string is a valid ISO-8601 instant.
    public var generatedDate: Date? { Snapshot.iso8601.date(from: generatedAt) }

    enum CodingKeys: String, CodingKey {
        case generatedAt = "generated_at"
        case summary
        case markets
        case crude
    }

    /// A decoder for the snapshot. Keys are mapped explicitly per type, so
    /// numeric segments like `return_1d` are handled unambiguously.
    public static var decoder: JSONDecoder { JSONDecoder() }

    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

/// One market's next-open call, its out-of-sample quality and its top drivers.
public struct Market: Codable, Equatable, Identifiable, Sendable {
    public let market: String
    public let symbol: String
    public let region: String
    public let session: String
    public let sessionOpenUtc: String
    public let pOpenUp: Double
    public let oosAuc: Double
    public let oosBrierSkill: Double
    public let oosAccuracy: Double
    public let baseRate: Double
    public let drivers: [Driver]
    /// Present only when the snapshot was produced under a hypothetical shock.
    public let pShocked: Double?
    public let pChange: Double?

    public var id: String { symbol }

    /// Parsed opening-auction time, if the string is a valid ISO-8601 instant.
    public var sessionOpenDate: Date? { Snapshot.iso8601.date(from: sessionOpenUtc) }

    enum CodingKeys: String, CodingKey {
        case market
        case symbol
        case region
        case session
        case sessionOpenUtc = "session_open_utc"
        case pOpenUp = "p_open_up"
        case oosAuc = "oos_auc"
        case oosBrierSkill = "oos_brier_skill"
        case oosAccuracy = "oos_accuracy"
        case baseRate = "base_rate"
        case drivers
        case pShocked = "p_shocked"
        case pChange = "p_change"
    }

    public init(
        market: String, symbol: String, region: String, session: String,
        sessionOpenUtc: String, pOpenUp: Double, oosAuc: Double, oosBrierSkill: Double,
        oosAccuracy: Double, baseRate: Double, drivers: [Driver],
        pShocked: Double? = nil, pChange: Double? = nil
    ) {
        self.market = market
        self.symbol = symbol
        self.region = region
        self.session = session
        self.sessionOpenUtc = sessionOpenUtc
        self.pOpenUp = pOpenUp
        self.oosAuc = oosAuc
        self.oosBrierSkill = oosBrierSkill
        self.oosAccuracy = oosAccuracy
        self.baseRate = baseRate
        self.drivers = drivers
        self.pShocked = pShocked
        self.pChange = pChange
    }
}

/// A single log-odds contribution behind a market's probability.
public struct Driver: Codable, Equatable, Identifiable, Sendable {
    public let name: String
    public let logOdds: Double

    public var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name
        case logOdds = "log_odds"
    }

    public init(name: String, logOdds: Double) {
        self.name = name
        self.logOdds = logOdds
    }
}

/// The crude readings the models feed on, for one benchmark.
public struct Crude: Codable, Equatable, Identifiable, Sendable {
    public let symbol: String
    public let name: String
    public let asOf: String
    public let close: Double
    public let return1d: Double
    public let return5d: Double
    public let volatility20d: Double
    public let shock: Double
    public let isShock: Bool

    public var id: String { symbol }

    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case asOf = "as_of"
        case close
        case return1d = "return_1d"
        case return5d = "return_5d"
        case volatility20d = "volatility_20d"
        case shock
        case isShock = "is_shock"
    }

    public init(
        symbol: String, name: String, asOf: String, close: Double, return1d: Double,
        return5d: Double, volatility20d: Double, shock: Double, isShock: Bool
    ) {
        self.symbol = symbol
        self.name = name
        self.asOf = asOf
        self.close = close
        self.return1d = return1d
        self.return5d = return5d
        self.volatility20d = volatility20d
        self.shock = shock
        self.isShock = isShock
    }
}
