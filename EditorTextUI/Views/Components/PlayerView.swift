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

    typealias UIViewControllerType = AVPlayerViewController

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let view = AVPlayerViewController()
        view.player = player
        view.showsPlaybackControls = false
        view.videoGravity = .resizeAspect
        print(player.status.rawValue)
        return view
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
        print(uiViewController.player?.status.rawValue)
    }
}
