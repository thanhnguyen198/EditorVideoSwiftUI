//
//  PlayerView.swift
//  EditorTextUI
//
//  Created by kii on 07/06/2023.
//

import AVKit
import SwiftUI

struct PlayerView: UIViewControllerRepresentable {
    var player: AVPlayer
    var videoGravity: AVLayerVideoGravity = .resizeAspect
    typealias UIViewControllerType = AVPlayerViewController

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let view = AVPlayerViewController()
        view.player = player
        view.showsPlaybackControls = false
        view.videoGravity = videoGravity
        player.play()

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }

        return view
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        uiViewController.player = player
    }
}
