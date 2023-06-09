//
//  UIView.swift
//  SwiftUITemplate
//
//  Created by apple on 17/04/2023.
//

import UIKit
// UIView + Animator
extension UIView {
    class Animator {
        typealias Completion = (Bool) -> Void
        typealias Animations = () -> Void

        private var animations: Animations
        private var completion: Completion?
        private let duration: TimeInterval
        private let delay: TimeInterval
        private let options: UIView.AnimationOptions

        init(duration: TimeInterval, delay: TimeInterval = 0, options: UIView.AnimationOptions = []) {
            animations = {}
            completion = nil
            self.duration = duration
            self.delay = delay
            self.options = options
        }

        func animations(_ animations: @escaping Animations) -> Self {
            self.animations = animations
            return self
        }

        func completion(_ completion: @escaping Completion) -> Self {
            self.completion = completion
            return self
        }

        func animate() {
            UIView.animate(withDuration: duration, animations: animations, completion: completion)
        }
    }

    final class SpringAnimator: Animator {
        private let damping: CGFloat
        private let velocity: CGFloat

        init(duration: TimeInterval, delay: TimeInterval = 0, damping: CGFloat, velocity: CGFloat, options: UIView.AnimationOptions = []) {
            self.damping = damping
            self.velocity = velocity

            super.init(duration: duration, delay: delay, options: options)
        }
    }

    func asImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            layer.render(in: context.cgContext)
        }
    }
}
