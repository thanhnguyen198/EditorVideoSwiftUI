//
//  VideoOverlay.swift
//  EditorTextUI
//
//  Created by kii on 12/06/2023.
//
import AVFoundation
import UIKit

class VideoOverlay: BaseOverlay {
    let url: URL

    override var layer: CALayer {
        let videoLayer = AVPlayerLayer()
        videoLayer.player = .init(url: url)
        videoLayer.frame = frame
        videoLayer.videoGravity = .resizeAspect
        videoLayer.displayIfNeeded()
        return videoLayer
    }

    init(url: URL, frame: CGRect, delay: TimeInterval, duration: TimeInterval, backgroundColor: UIColor = UIColor.clear) {
        self.url = url
        super.init(frame: frame, delay: delay, duration: duration)
    }
}
