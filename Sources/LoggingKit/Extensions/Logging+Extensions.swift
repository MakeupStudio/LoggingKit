//
//  Logging+Extensions.swift
//  Logging
//
//  Created by Maxim Krouk on 3/31/20.
//

// MARK: - Logger

extension Logger {
    public init<T>(for type: T.Type) {
        self.init(label: String(reflecting: type) + ".logger")
    }
}

// MARK: - Logger.Message

extension Logger.Message {
    
    public init(_ message: String) {
        self.init(stringLiteral: message)
    }
    
    @inlinable public static func dump(_ objects: Any...) -> Self { dump(objects) }
    
    public static func dump(_ objects: [Any]) -> Self
    { .init(objects.map(dump(object:)).joined(separator: "\n\n")) }
    
    private static func dump(object: Any) -> String {
        var output = ""
        Swift.dump(object, to: &output)
        if output.hasSuffix("\n") { output.removeLast() }
        return output
    }
    
}

// MARK: - Logger.Level

extension Logger.Level {
    @inlinable var emoji: String {
        switch self {
        case .trace    : return "💬"
        case .debug    : return "🔘"
        case .info     : return "💡"
        case .notice   : return "🔔"
        case .warning  : return "⚠️"
        case .error    : return "❌"
        case .critical : return "🆘"
        }
    }
}

// MARK: - Codable

extension Logger.MetadataValue: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value): try container.encode(value)
        case let .stringConvertible(value): try container.encode(value.description)
        case let .dictionary(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Logger.Metadata.self) {
            self = .dictionary(value)
        } else {
            self = .array(try container.decode([Logger.Metadata.Value].self))
        }
    }
}

extension Logger.Message: Codable {
    private enum CodingKeys: String, CodingKey { case value }
    public init(from decoder: Decoder) throws {
        self.init(
            try decoder
                .container(keyedBy: CodingKeys.self)
                .decode(String.self, forKey: .value)
        )
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .value)
    }
}
