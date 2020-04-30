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
    public var publisher: AnyPublisher<Value, Never> { objectWillChange
        .map { self.wrappedValue }
        .eraseToAnyPublisher()
    }
}
#endif

extension Box where Value: ExpressibleByArrayLiteral {
    public convenience init() { self.init([]) }
}

extension Box where Value: ExpressibleByDictionaryLiteral {
    public convenience init() { self.init([:]) }
}

extension Box where Value: ExpressibleByStringLiteral {
    public convenience init() { self.init("") }
}

extension Box where Value: ExpressibleByNilLiteral {
    public convenience init() { self.init(nil) }
}

@propertyWrapper
@dynamicMemberLookup
public final class Box<Value> {
    #if canImport(Combine)
    public var wrappedValue: Value {
        willSet {
            if #available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *) {
                self.objectWillChange.send()
            }
        }
    }
    #else
    public var wrappedValue: Value
    #endif
    
    public var content: Value {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }
    
    public convenience init(_ wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue)
    }
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public var projectedValue: Ref<Value> { ref }
    public var ref: Ref<Value> {
        Ref<Value>(
            read: { self.wrappedValue },
            write: { self.wrappedValue = $0 }
        )
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<Value, U>) -> U {
        get { self.wrappedValue[keyPath: keyPath] }
    }
    
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Value, U>) -> U {
        get { self.wrappedValue[keyPath: keyPath] }
        set { self.wrappedValue[keyPath: keyPath] = newValue }
    }
    
    public subscript<U>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, U>) -> U {
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
