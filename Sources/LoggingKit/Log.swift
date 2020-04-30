//
//  Log.swift
//  LoggingKit
//
//  Created by Maxim Krouk on 4/29/20.
//

import Foundation
import Logging

public struct Log: Identifiable, Equatable, Codable {
    public let id = UUID()
    public let date = Date()
    public var level: Logger.Level
    public var message: Logger.Message
    public var label: String
    public var metadata: Logger.Metadata?
    public var handlerMetadata: Logger.Metadata
    public var function: String
    public var file: String
    public var line: UInt
    
    public func redirect(to factory: (String) -> LogHandler) {
        factory(label).log(
            level: level,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }
}

extension Log: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Log {
    public func dump() -> String { LoggingKit.dump(object: self) }
    public func dump<Target: TextOutputStream>(to target: inout Target) { target.write(dump()) }
    public func dump(to handle: FileHandle) { dump().data(using: .utf8).map(handle.write) }
}

public func description(for log: Log) -> String {
    let metadata = getMetadataIfPresent(log.handlerMetadata, log.metadata)
    return
        """
        \(log.level.emoji) \(log.label) [\(log.level.rawValue.uppercased())]
        # startlog(\(log.id))
        # \(log.date)
        # function: "\(log.function)"
        # file: \(log.file)
        # line \(log.line)\(metadata)
        # message:
        :»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»:
        \(log.message.description)
        :««««««««««««««««««««««««««««««««««««««««««««:
        # endlog(\(log.id))\n
        """
}

private func getMetadataIfPresent(
    _ handlerMetadata: Logger.Metadata,
    _ logMetadata: Logger.Metadata?
) -> String {
    var output = ""
    if !handlerMetadata.isEmpty {
        output.append("\n# logger.metadata\n")
        output.append(Logger.Message.dump(handlerMetadata).description)
    }
    
    if let metadata = logMetadata {
        output.append("\n# logging.metadata\n")
        output.append(Logger.Message.dump(metadata).description)
    }
    
    if output.hasSuffix("\n") { output.removeLast() }
    return output
}
