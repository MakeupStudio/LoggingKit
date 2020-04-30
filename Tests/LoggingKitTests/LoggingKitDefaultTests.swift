import XCTest
@testable import LoggingKit
@testable import Logging

final class LoggingKitDefaultTests: XCTestCase {
    let box = Box<[Log]>()
    
    override func setUp() {
        if !isLoggingConfigured {
            LoggingSystem.bootstrap(output: box)
            isLoggingConfigured = true
        } else {
            let _box = box
            LoggingSystem.bootstrapInternal { label in
                BoxLogHandler(label: label, output: _box)
            }
        }
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
        preformLogging(with: Logger(for: Self.self))
        
        // expect to see descriptions
        // TODO: Add regex
        box.content.map(description(for:)).forEach { print($0) }
    }
    
    func testLoggable() {
        struct Test1: Loggable {}
        struct Test2: Loggable {}
        
        XCTAssertEqual(Test1().logger.label, Test1.logger.label)
        XCTAssertEqual(Test1().logger.logLevel, Test1.logger.logLevel)
        
        XCTAssertNotEqual(Test1.logger.label, Test2.logger.label)
    }

    static var allTests = [
        ("testLogging", testLogging),
        ("testLoggable", testLoggable)
    ]
}
