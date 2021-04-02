//
//  URLRequestExtension.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 31.03.21.
//

import Foundation
 
extension URLRequest {
    
    mutating func setHTTPBody(parameters: [String: AnyObject]?) {
        if let parameters = parameters {
            var components: [(String, String)] = []
            for (key, value) in parameters {
                components += queryComponents(key, value)
            }
            let bodyString = components.map { "\($0)=\($1)" }.joined(separator: "&")
            httpBody = bodyString.data(using: String.Encoding.utf8)
        } else {
            httpBody = nil
        }
    }
    
}

extension URLRequest {
    
    private func queryComponents(_ key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
    
}
