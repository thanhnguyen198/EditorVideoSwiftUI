//
//  UIViewControllerCoordinator.swift
//  SwiftUITemplate
//
//  Created by apple on 07/04/2023.
//

import Coordinator
import Foundation

extension UIViewControllerCoordinator {
    func dismiss(animated: Bool = true, completion: @escaping () -> Void) {
        rootViewController?.dismiss(animated: animated, completion: completion)
    }
}
