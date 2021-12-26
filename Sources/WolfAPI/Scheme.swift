import WolfBase

public struct Scheme: Enumeration, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    // RawRepresentable
    public init?(rawValue: String) { self.init(rawValue) }
}

extension Scheme {
    public static let http = Scheme("http")
    public static let https = Scheme("https")
}
