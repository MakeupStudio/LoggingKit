//
//  LoggingSystem.swift
//  Logging
//
//  Created by Maxim Krouk on 4/2/20.
//

import Logging

extension LoggingSystem {
    /// Bootstraps the logging system
    public static func bootstrap(
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:]
    ) -> Box<Log?> {
        let box = Box(Log?.none)
        self.bootstrap(
            level: level,
            metadata: metadata,
            output: box
        )
        return box
    }
    
    /// Bootstraps the logging system
    public static func bootstrap<Buffer: LogOutputStream>(
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        output: Box<Buffer>
    ) {
        self.bootstrap { label in
            BoxLogHandler(
                label: label,
                metadata: metadata,
                logLevel: level,
                output: output
            )
        }
    }
}
