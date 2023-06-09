//
//  Constant.swift
//  SwiftUITemplate
//
//  Created by apple on 30/03/2023.
//

import Foundation
import UIKit

let kAPIRequestTimeout: TimeInterval = 30
let kUserDefault = UserDefaults.standard
let kMainThread = DispatchQueue.main
let kScreen = UIScreen.main
let kDevice = UIDevice.current
let kScreenSize = CGSize(width: kScreen.bounds.width, height: kScreen.bounds.height)

struct Constant {
    static let apiKeyWeather = "ee2b14a872b6652bd12a99f550125b96"
    struct NavigationBar {
        static var height: CGFloat {
            return 40
        }
    }
}
