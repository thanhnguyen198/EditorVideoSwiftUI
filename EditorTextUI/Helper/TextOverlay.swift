//
//  TextOverlay.swift
//  AddTextSwiftUI
//
//  Created by kii on 06/06/2023.
//

import Foundation
import UIKit

class TextOverlay: BaseOverlay {
    let text: String
    let textColor: UIColor
    let font: UIFont
    let textAlignment: NSTextAlignment
    let fontSize: CGFloat
    
    override var layer: CALayer {
        let textLayer = CATextLayer()
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.foregroundColor = textColor.cgColor
        textLayer.string = text
        textLayer.isWrapped = true
        textLayer.font = font
        textLayer.fontSize = fontSize
        textLayer.alignmentMode = layerAlignmentMode
        textLayer.frame = frame
        textLayer.opacity = 0.0
        textLayer.displayIfNeeded()
        return textLayer
    }

    private var layerAlignmentMode: CATextLayerAlignmentMode {
        switch textAlignment {
        case NSTextAlignment.left:
            return CATextLayerAlignmentMode.left
        case NSTextAlignment.center:
            return CATextLayerAlignmentMode.center
        case NSTextAlignment.right:
            return CATextLayerAlignmentMode.right
        case NSTextAlignment.justified:
            return CATextLayerAlignmentMode.justified
        case NSTextAlignment.natural:
            return CATextLayerAlignmentMode.natural
        @unknown default:
            return CATextLayerAlignmentMode.center
        }
    }

    init(text: String,
         frame: CGRect,
         delay: TimeInterval,
         duration: TimeInterval,
         backgroundColor: UIColor = UIColor.clear,
         textColor: UIColor = UIColor.black,
         font: UIFont = UIFont.systemFont(ofSize: 12),
         textAlignment: NSTextAlignment = NSTextAlignment.center,
         fontSize: CGFloat = 12) {
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        self.fontSize = fontSize
        super.init(frame: frame, delay: delay, duration: duration, backgroundColor: backgroundColor)
    }
}
