//
//  UIApplication.swift
//  SwiftUITemplate
//
//  Created by apple on 30/03/2023.
//

import UIKit

extension UIApplication {
    static var statusBarHeight: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        return windowScene.statusBarManager?.statusBarFrame.height ?? 0
    }
}
