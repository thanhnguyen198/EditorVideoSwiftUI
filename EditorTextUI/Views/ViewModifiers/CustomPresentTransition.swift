//
//  CustomPresentTransition.swift
//  iosApp
//
//  Created by apple on 02/12/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import Foundation
import UIKit

class CustomPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    enum TransitionType {
        case present
        case dismiss
    }

    var transitionType: TransitionType
    var duration: TimeInterval

    private lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        return view
    }()

    init(_ transitionType: TransitionType, _ duration: TimeInterval) {
        self.transitionType = transitionType
        self.duration = duration
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        switch transitionType {
        case .present:
            presentAnimateTransition(using: transitionContext, viewToAnimate: toVC.view)
        case .dismiss:
            dismissAnimateTransition(using: transitionContext, viewToAnimate: fromVC.view)
        }
    }

    private func presentAnimateTransition(using context: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        let containerView = context.containerView
        containerView.addSubview(maskView)
        maskView.frame = containerView.bounds
        maskView.alpha = 0

        UIView.Animator(duration: duration)
            .animations {
                self.maskView.alpha = 1.0
            }
            .animate()

        containerView.addSubview(viewToAnimate)
        viewToAnimate.frame = CGRect(x: 0, y: containerView.frame.height, width: containerView.frame.width, height: containerView.frame.height)

        UIView.Animator(duration: duration)
            .animations {
                viewToAnimate.frame.origin.y = 0
            }
            .completion({ finished in
                guard finished else { return }
                context.completeTransition(true)
            })
            .animate()
    }

    private func dismissAnimateTransition(using context: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        let containerView = context.containerView
        UIView.Animator(duration: duration)
            .animations {
                self.maskView.alpha = 0
            }
            .completion { finished in
                guard finished else { return }
                self.maskView.removeFromSuperview()
            }
            .animate()

        UIView.Animator(duration: duration)
            .animations {
                viewToAnimate.frame.origin.y = containerView.frame.height
            }
            .completion({ finished in
                guard finished else { return }
                viewToAnimate.removeFromSuperview()
                context.completeTransition(true)
            })
            .animate()
    }
}
