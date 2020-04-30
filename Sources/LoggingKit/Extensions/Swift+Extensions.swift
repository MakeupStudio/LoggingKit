//
//  Swift+Extension.swift
//  LoggingKit
//
//  Created by Maxim Krouk on 4/29/20.
//

internal func dump(object: Any) -> String {
    var output = ""
    Swift.dump(object, to: &output)
    return output
}
