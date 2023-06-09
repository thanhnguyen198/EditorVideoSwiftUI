//
//  HTTPURLResponse.swift
//  SwiftUITemplate
//
//  Created by apple on 30/03/2023.
//

import Foundation
import UIKit

extension HTTPURLResponse {
    enum Status {
        case success
        case failed
    }

    var status: Status {
        if (200 ... 299).contains(statusCode) {
            return .success
        } else {
            return .failed
        }
    }
}
