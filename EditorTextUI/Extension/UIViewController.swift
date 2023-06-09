//
//  UIViewController.swift
//  SwiftUITemplate
//
//  Created by apple on 29/03/2023.
//

import SwiftUI

final class CustomHostingController: UIHostingController<AnyView> {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
}

extension UIViewController {
    @discardableResult
    func present<Content: View>(style: UIModalPresentationStyle = .overFullScreen, transitionStyle: UIModalTransitionStyle = .crossDissolve, background: UIColor? = nil, @ViewBuilder builder: () -> Content) -> UIViewController {
        let toPresent = CustomHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.modalTransitionStyle = transitionStyle
        toPresent.view.backgroundColor = background ?? UIColor.black.withAlphaComponent(0.5)
        if style == .custom {
            toPresent.transitioningDelegate = self.transitioningDelegate
            toPresent.view.backgroundColor = .clear
        }
        toPresent.rootView = AnyView(
            builder()
                .environment(\.rootViewController, toPresent)
        )
        present(toPresent, animated: true, completion: nil)
        return toPresent
    }

    func showAlert(title: String? = nil, message: String? = nil, action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            action?()
        }))
        present(alert, animated: true)
    }

    static func topViewController(_ base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let tab = base as? UITabBarController {
            if let viewControllers = tab.viewControllers, viewControllers.indices.contains(tab.selectedIndex) {
                let presented = viewControllers[tab.selectedIndex]
                return topViewController(presented)
            }
        }
        if let nav = base as? UINavigationController {
            let vc = nav.viewControllers.last
            return topViewController(vc)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
