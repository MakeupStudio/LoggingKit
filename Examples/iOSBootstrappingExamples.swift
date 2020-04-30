/// See `BootstrappingExamples.swift` for `bootstrapLoggingSystem` functions.

import LoggingKit
import UIKit

/// If you want to store logs, you can save them
/// by encoding with encoder (to restore them later),
/// or just to save logs dump on the disk

/// so we need a file to store logs in
/// here are some functions that can be used
/// `|`
/// `v`
// MARK: - Common

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        createLogsFileIfNeeded()
        return true
    }
}

extension AppDelegate {
    static var internalFolderURL: URL? { FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first?.appendingPathComponent(".internal")
    }
    
    static var logsFileURL: URL? { AppDelegate
        .internalFolderURL?
        .appendingPathComponent("logsfile")
    }
    
    func createInternalFolderIfNeeded() {
        Self.internalFolderURL.map { url in
            guard !FileManager.default.fileExists(atPath: url.path) else { return }
            try? FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: .none
            )
        }
    }
    
    func createLogsFileIfNeeded() {
        createInternalFolderIfNeeded()
        Self.logsFileURL.map { url in
            guard !FileManager.default.fileExists(atPath: url.path) else { return }
            FileManager.default.createFile(
                atPath: url.path,
                contents: .none,
                attributes: .none
            )
        }
    }
}

/// You can use your custom handlers by implementing `: LogOutputStream`
/// `|`
/// `v`
// MARK: Example 1

class AppDelegateExample1: AppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        guard super.application(application, didFinishLaunchingWithOptions: launchOptions)
        else { return false }
        
        Self.logsFileURL.map { url in
            // Box<CustomLogOutputStreamExample> is returned,
            // but i won't handle it, just because i can 😎
            _ = try? bootstrapLoggingSystem(level: .info, url)
        }
        return true
    }
}

/// Or use default Box LogBuffer, that stores an array of logs
/// `|`
/// `v`
// MARK: Example 2

class AppDelegateExample2: AppDelegate {
    
    static private(set) var appLogsBox: Box<[Log]> = .init()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        guard super.application(application, didFinishLaunchingWithOptions: launchOptions)
        else { return false }
        
        Self.appLogsBox = bootstrapLoggingSystem(level: .info)
        return true
    }
}

/// Actually you can do anything you want
/// `|`
/// `v`
// MARK: Example 3

import Combine

@available(iOS 13.0, *)
class AppDelegateExample3: AppDelegate {
    
    static private(set) var appLogsBox: Box<[Log]> = .init()
    static private var logsFileHandle: FileHandle? = try? logsFileURL.map(FileHandle.init(forWritingTo:))
    static private var subscriptions: Set<AnyCancellable> = []
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        guard super.application(application, didFinishLaunchingWithOptions: launchOptions)
        else { return false }
        
        setupLogs()
        return true
    }
    
    func setupLogs() {
        createLogsFileIfNeeded()
        let box: Box<Log?> = bootstrapLoggingSystem(level: .info)
        box.publisher.sink { optionalLog in
            optionalLog.map { log in
                // You can store logs somewhere
                Self.appLogsBox.content.append(log)
                
                // or dump them into some file
                Self.logsFileHandle.map(log.dump(to:))
                
                // or print them to some file
                log.prettyPrint(to: .standardOutput)
                
                // or send them somewhere
                if Self.appLogsBox.count > 100 {
                    var req = URLRequest(url: URL(string: "some url")!)
                    req.httpBody = try? JSONEncoder().encode(Self.appLogsBox.content)
                    URLSession.shared.dataTask(with: req).resume()
                    Self.appLogsBox.content.removeAll()
                }
            }
        }.store(in: &Self.subscriptions)
    }
}
