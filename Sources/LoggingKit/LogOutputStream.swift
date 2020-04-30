//
//  LogOutputStream.swift
//  LoggingKit
//
//  Created by Maxim Krouk on 4/29/20.
//

import Foundation

public protocol LogOutputStream {
    mutating func write(_: Log)
}

public protocol LogOutputStreamable {
    func write<Target>(to target: inout Target) where Target : LogOutputStream
}

extension Array: LogOutputStream where Element == Log {
    mutating public func write(_ log: Log) { append(log) }
}

extension Log: LogOutputStream {
    mutating public func write(_ log : Log) { self = log }
}

extension Optional: LogOutputStream where Wrapped == Log {
    mutating public func write(_ log : Log) { self = .some(log) }
}
