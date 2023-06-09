//
//  ImageOverlay.swift
//  AddTextSwiftUI
//
//  Created by kii on 06/06/2023.
//

import Foundation
import UIKit

class ImageOverlay: BaseOverlay {
    let image: UIImage

    override var layer: CALayer {
        let imageLayer = CALayer()
        imageLayer.contents = image.cgImage
        imageLayer.backgroundColor = backgroundColor.cgColor
        imageLayer.frame = frame
        imageLayer.opacity = 0.0

        return imageLayer
    }

    init(image: UIImage,
         frame: CGRect,
         delay: TimeInterval,
         duration: TimeInterval,
         backgroundColor: UIColor = UIColor.clear) {
        self.image = image

        super.init(frame: frame, delay: delay, duration: duration, backgroundColor: backgroundColor)
    }
}
