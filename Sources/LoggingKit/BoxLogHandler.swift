//
//  Logging.swift
//  Logging
//
//  Created by Maxim Krouk on 3/31/20.
//

import Foundation

struct BoxLogHandler<Buffer: LogOutputStream>: Logging.LogHandler {
    let label: String
    var metadata: Logger.Metadata
    var logLevel: Logger.Level
    var output: Box<Buffer>
    
    private let lock = Lock()
    
    @inlinable init(
        label: String,
        metadata: Logger.Metadata = [:],
        logLevel: Logger.Level = .info,
        output: Box<Buffer>
    ) {
        self.label = label
        self.metadata = metadata
        self.logLevel = logLevel
        self.output = output
    }
    
    @inlinable func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        guard logLevel <= level else { return }
        let log = Log(
            level: level,
            message: message,
            label: label,
            metadata: metadata,
            handlerMetadata: self.metadata,
            function: function,
            file: file,
            line: line
        )
        lock.withLock {
            output.content.write(log)
        }
    }
    
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
    
}
