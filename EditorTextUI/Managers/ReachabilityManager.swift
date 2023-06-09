//
//  ReachabilityManager.swift
//  SwiftUITemplate
//
//  Created by apple on 05/04/2023.
//

import Foundation
import Reachability

class ReachabilityManager {
    static var shared = ReachabilityManager()

    var hasConnectivity: Bool {
        do {
            let reachability: Reachability = try Reachability()
            let networkStatus = reachability.connection
            switch networkStatus {
            case .unavailable, .none:
                return false
            case .wifi, .cellular:
                return true
            }
        } catch {
            return false
        }
    }
}
