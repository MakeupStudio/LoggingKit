# LoggingKit

Simple logging kit written in Swift.

## Usage

1. Bootstrap logging system globally

Simple way:
```swift
// AppDelegate.swift
import LoggingKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let logs = Box<[Log]>()
    func application(..., didFinishLaunchingWithOptions...) -> Bool {
        LoggingSystem.bootstrap(level: .info, output: Self.logs)
    }
    // ...
}
```
Better way:
```swift
// AppDelegate.swift
import Combine
import LoggingKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var loggerSubscription: AnyCancellable?
    static let internalFolder: URL? = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first.map { $0.appendingPathComponent(".internal") }
    }()
    static let logsFileURL: URL? { 
        internalFolder
        .appendingPathComponent(".logs") 
    }
    
    func bootstrapLoggingSystem() {
        do {
            try Self.internalFolder
                .map { url in
                    try FileManager.default.createDirectory(
                        at: url, withIntermediateDirectories: true,
                        attributes: nil
                    )
            }
            Self.logsFileURL
                .map { url in 
                    let box = Box<Log?>()
                    loggerSubscription = LoggingSystem.bootstrap(level: .info, output: box)
                    box.publisher.sink { log in
                        log.dump(to: FileHandle(forWritingTo: url))
                        
                        #if DEBUG
                        log.prettyPrint(to: .standardOutput)
                        // Or use any Encoder if you want to, just do anything you want.
                        #endif
                    }
            }
        } catch {
            // logs file could not be created
        }
    }
    
    func application(..., didFinishLaunchingWithOptions...) -> Bool {
        bootstrapLoggingSystem()
    }
    
}
```

2. Passthrough convenience types

```swift
// LoggingKit.swift
import LoggingKit

typealias Loggable = LoggingKit.Loggable
typealias Log = LoggingKit.Log
```

3. Log

```swift
class ProfileViewModel: Loggable {
    // ...
    func logout() {
        userManager.logout(
            onSuccess: { [weak self] in
            self?.coordinator.go(to: .signIn)
                Self.logger.trace("User signed out.")
            }, 
            onFailure: { [weak self] error in
                Self.logger.trace("User logout failed.")
                Self.logger.info(.dump(error))
            })
    }
}
```

4. Grab logs

For simple bootstrap

```swift
class LoggingViewModel {
    var logs: [Log] { AppDelegate.logs.content }
}
```
