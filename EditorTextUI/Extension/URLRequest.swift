//
//  URLRequest.swift
//  SwiftUITemplate
//
//  Created by apple on 30/03/2023.
//

import Foundation
import Alamofire

extension URLRequest {
    mutating func setAuthorizationHeader(username: String, password: String) {
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else { return }
        let base64LoginString = loginData.base64EncodedString()
        setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    }

    var parameters: Parameters {
        guard let httpBody = httpBody else {
            return [:]
        }
        do {
            let body = try JSONSerialization.jsonObject(with: httpBody, options: []) as? Parameters
            return body ?? [:]
        } catch {
            return [:]
        }
    }
}
