//
//  Loggable.swift
//  Logging
//
//  Created by Maxim Krouk on 4/2/20.
//

/// This protocol provides shared static and instance loggers for your types
///
/// `No implementation is needed`
public protocol Loggable {}

// MARK: Module loggers
private var sharedLoggers: [ObjectIdentifier: Logger] = [:]
extension Loggable {
    private static var _loggerID: ObjectIdentifier { .init(self) }
    
    /// Shared logger for the type
    ///
    /// `This property should not be overriden`
    @inlinable public var logger: Logger { Self.logger }
    
    /// Shared logger for the type
    ///
    /// `This property must not be overriden`
    public static var logger: Logger {
        if let logger = sharedLoggers[_loggerID] { return logger }
        
        let logger = Logger(for: self)
        sharedLoggers[_loggerID] = logger
        return logger
    }
    
    /// Removes shared logger for the type
    ///
    /// `This property should not be overriden`
    ///
    /// _Note: Shared logger will be recreated as soon as you access `logger` property_
    public static func releaseLogger() {
        sharedLoggers[_loggerID] = .none
    }
}
