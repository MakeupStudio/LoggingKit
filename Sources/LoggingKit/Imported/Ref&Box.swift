//
//  Box.swift
//  Logging
//
//  Created by Maxim Krouk on 4/2/20.
//
// https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#ref--box

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Box: ObservableObject {
    public var publisher: AnyPublisher<Content, Never> { objectWillChange
        .map { self.wrappedValue }
        .eraseToAnyPublisher()
    }
}
#endif

extension Box: ExpressibleByNilLiteral where Content: ExpressibleByNilLiteral {
    public convenience init() { self.init(nil) }
    public convenience init(nilLiteral: Void) { self.init(nil) }
}

extension Box: ExpressibleByFloatLiteral where Content: ExpressibleByFloatLiteral {
    public convenience init(floatLiteral value: Content.FloatLiteralType) {
        self.init(Content(floatLiteral: value))
    }
}

extension Box: ExpressibleByIntegerLiteral where Content: ExpressibleByIntegerLiteral {
    public convenience init(integerLiteral value: Content.IntegerLiteralType) {
        self.init(Content(integerLiteral: value))
    }
}

extension Box: ExpressibleByBooleanLiteral where Content: ExpressibleByBooleanLiteral {
    public convenience init(booleanLiteral value: Content.BooleanLiteralType) {
        self.init(Content(booleanLiteral: value))
    }
}

extension Box: ExpressibleByExtendedGraphemeClusterLiteral where Content: ExpressibleByExtendedGraphemeClusterLiteral {
    public convenience init(extendedGraphemeClusterLiteral value: Content.ExtendedGraphemeClusterLiteralType) {
        self.init(Content(extendedGraphemeClusterLiteral: value))
    }
}

extension Box: ExpressibleByUnicodeScalarLiteral where Content: ExpressibleByUnicodeScalarLiteral {
    public convenience init(unicodeScalarLiteral value: Content.UnicodeScalarLiteralType) {
        self.init(Content(unicodeScalarLiteral: value))
    }
}

extension Box: ExpressibleByStringLiteral where Content: ExpressibleByStringLiteral {
    public convenience init(stringLiteral value: Content.StringLiteralType) {
        self.init(Content(stringLiteral: value))
    }
}

extension Box where Content: ExpressibleByArrayLiteral {
    public convenience init() { self.init([]) }
}

extension Box where Content: ExpressibleByDictionaryLiteral {
    public convenience init() { self.init([:]) }
}

extension Box where Content: ExpressibleByStringLiteral {
    public convenience init() { self.init("") }
}

@propertyWrapper
@dynamicMemberLookup
public final class Box<Content> {
    #if canImport(Combine)
    public var content: Content {
        willSet {
            if #available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *) {
                self.objectWillChange.send()
            }
        }
    }
    #else
    public var content: Content
    #endif
    
    public var wrappedValue: Content {
        get { content }
        set { content = newValue }
    }
    
    public convenience init(_ wrappedValue: Content) {
        self.init(wrappedValue: wrappedValue)
    }
    
    public init(wrappedValue: Content) {
        self.content = wrappedValue
    }
    
    public var projectedValue: Ref<Content> { ref }
    public var ref: Ref<Content> {
        Ref<Content>(
            read: { self.wrappedValue },
            write: { self.wrappedValue = $0 }
        )
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<Content, U>) -> U {
        get { self.wrappedValue[keyPath: keyPath] }
    }
    
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Content, U>) -> U {
        get { self.wrappedValue[keyPath: keyPath] }
        set { self.wrappedValue[keyPath: keyPath] = newValue }
    }
    
    public subscript<U>(dynamicMember keyPath: ReferenceWritableKeyPath<Content, U>) -> U {
        get { self.wrappedValue[keyPath: keyPath] }
        set { self.wrappedValue[keyPath: keyPath] = newValue }
    }
}

@propertyWrapper
@dynamicMemberLookup
public struct Ref<Value> {
    public let read: () -> Value
    public let write: (Value) -> Void
    
    public var wrappedValue: Value {
        get { return read() }
        nonmutating set { write(newValue) }
    }
    
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Value, U>) -> Ref<U> {
        return Ref<U>(
            read: { self.wrappedValue[keyPath: keyPath] },
            write: { self.wrappedValue[keyPath: keyPath] = $0 })
    }
}

#if canImport(SwiftUI)
import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Ref {
    public var binding: Binding<Value> { .init(get: read, set: write) }
}
#endif
