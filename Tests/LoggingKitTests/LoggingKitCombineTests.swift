import XCTest
@testable import LoggingKit
@testable import Logging
#if canImport(Combine)
import Combine
#endif

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
final class LoggingKitCombineTests: XCTestCase {
    var subscriptions = Set<AnyCancellable>()
    var box = Box<Log?>()
    
    override func setUp() {
        #if canImport(Combine)
        let box = LoggingSystem._bootstrap()
        box.publisher
            .sink { $0.map { $0.dump(to: .standardOutput) } }
            .store(in: &subscriptions)
        #endif
    }
    
    func preformLogging(with logger: Logger) {
        // Expect to see message
        logger.log(level: .trace, "My message")
        logger.log(level: .debug, "My message")
        logger.log(level: .info, "My message")
        logger.log(level: .notice, "My message")
        logger.log(level: .warning, "My message")
        logger.log(level: .error, "My message")
        logger.log(level: .critical, "My message", metadata: ["Some": "MTD", "Another": "MTD"])
        
        // Expect to see object dump
        logger.trace(.dump(Date()))
        logger.debug(.dump(Date()))
        logger.notice(.dump(Date()))
        logger.warning(.dump(Date()))
        logger.error(.dump(Date()))
        logger.info(.dump(Date()))
        logger.critical(.dump(Date()), metadata: ["Some": "MTD", "Another": "MTD"])
    }
    
    func testLogging() {
        // expect to see dumps
        // TODO: Add regex
        preformLogging(with: Logger(for: Self.self))
    }

    static var allTests = [
        ("testLogging", testLogging)
    ]
}
