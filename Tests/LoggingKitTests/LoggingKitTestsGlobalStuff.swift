@testable import Logging
@testable import LoggingKit

extension LoggingSystem {
    internal static func _bootstrap(
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:]
    ) -> Box<Log?> {
        let box = Box(Log?.none)
        self._bootstrap(
            level: level,
            metadata: metadata,
            output: box
        )
        return box
    }

    public static func _bootstrap<Buffer: LogOutputStream>(
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        output: Box<Buffer>
    ) {
        self.bootstrapInternal { label in
            BoxLogHandler(
                label: label,
                metadata: metadata,
                logLevel: level,
                output: output
            )
        }
    }
}
