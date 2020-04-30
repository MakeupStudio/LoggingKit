//
//  String+Extensions.swift
//  Mealcontrol
//
//  Created by Maxim Krouk on 3/6/20.
//  Copyright © 2020 Maxim Krouk. All rights reserved.
//

// MARK: Length adjustments
extension String {
    @inlinable func supplementing(to count: Int, with template: String) -> String {
        var output = self
        output.supplement(to: count, with: template)
        return output
    }
    
    @inlinable mutating func supplement(to count: Int, with template: String) {
        append(String(repeating: template, count: count - self.count))
    }
}

// MARK: Static factory
extension String {
    static var whitespace: String { " " }
    static var newline: String { "\n" }
    static var empty: String { "" }
    static var tab: String { "\t" }
}
