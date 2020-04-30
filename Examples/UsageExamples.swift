//
//  UsageExamples.swift
//  Logging
//
//  Created by Maxim Krouk on 4/30/20.
//

import Combine
import Foundation
import LoggingKit

// MARK: Publisher Extension

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    
    /// Convenience method for logging
    func logError(level: Logger.Level = .error, to logger: Logger)
    -> Publishers.MapError<Self, Failure> {
        logError(Error.self, level: level, to: logger)
    }
    
    /// Convenience method for typed logging
    func logError<T>(_ type: T.Type, level: Logger.Level = .error, to logger: Logger)
    -> Publishers.MapError<Self, Failure> {
        mapError { error in
            if error is T { logger.log(level: level, .dump(error)) }
            return error
        }
    }
    
    /// Convenience method for erasing errors
    func eraseError() -> Publishers.MapError<Self, Error> { mapError { $0 } }
    
    /// Convenience method for handling sink call sites
    func sink(
        function: String = #function,
        file: String = #file,
        line: UInt = #line,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>, String, String, UInt) -> Void,
        receiveValue: @escaping (Output) -> Void
    ) -> AnyCancellable {
        sink(
            receiveCompletion: { receiveCompletion($0, function, file, line) },
            receiveValue: receiveValue
        )
    }
    
}

// MARK: Loggable NetworkService Example

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class NetworkService: Loggable {
    private var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func send(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        session
            .dataTaskPublisher(for: request)
            .logError(level: .warning, to: logger)
            .map(\.data)
            .eraseError()
            .eraseToAnyPublisher()
    }
    
    func send<Response: Decodable, Decoder: TopLevelDecoder>(
        _ request: URLRequest,
        for response: Response.Type,
        decoder: Decoder
    ) -> AnyPublisher<Response, Error> where Decoder.Input == Data {
        send(request)
            .decode(type: response, decoder: decoder)
            .logError(DecodingError.self, level: .warning, to: logger)
            .eraseToAnyPublisher()
    }
}

// MARK: Loggable Extension for logging `.sink` completions

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Loggable {
    static func logCompletion<T>(
        _ completion: Subscribers.Completion<T>,
        function: String = #function,
        file: String = #file,
        line: UInt = #line
    ) {
        switch completion {
        case .failure(let error):
            logger.info("Got error in completion: \(dump(error))",
                file: file,
                function: function,
                line: line
            )
        case .finished:
            logger.trace("Operation completed",
                file: file,
                function: function,
                line: line
            )
        }
    }
}

// MARK: Loggable ViewModel Example

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class SomeViewModel: Loggable {
    private var subscriptions: Set<AnyCancellable> = []
    
    let networkService: NetworkService
    let sourceURL: URL
    var source: String?
    
    init(networkService: NetworkService, sourceURL: URL) {
        self.networkService = networkService
        self.sourceURL = sourceURL
    }
    
    func loadSource() {
        networkService.send(.init(url: sourceURL), for: String.self, decoder: JSONDecoder())
            .sink(receiveCompletion: Self.logCompletion) { [weak self] in self?.source = $0 }
            .store(in: &subscriptions)
    }
}
