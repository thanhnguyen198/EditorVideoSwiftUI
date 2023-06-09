//
//  VideoOverProcessor.swift
//  AddTextSwiftUI
//
//  Created by kii on 06/06/2023.
//

import AVFoundation
import UIKit

class VideoOverlayProcessor: ObservableObject {
    let inputURL: URL
    let outputURL: URL

    var exportProgressBarTimer = Timer() // initialize timer
    var outputPresetName: String = AVAssetExportPresetHighestQuality
    @Published var progress: Float = 0.0

    private var overlays: [BaseOverlay] = []

    var videoSize: CGSize {
        let asset = AVURLAsset(url: inputURL)
        let track = asset.tracks(withMediaType: AVMediaType.video).first
        if let track = track, isPortrait(track.preferredTransform) {
            let naturalSize = track.naturalSize
            return .init(width: naturalSize.height, height: naturalSize.width)
        } else {
            return track?.naturalSize ?? .zero
        }
    }

    var videoDuration: TimeInterval {
        let asset = AVURLAsset(url: inputURL)
        return asset.duration.seconds
    }

    private var asset: AVAsset {
        return AVURLAsset(url: inputURL)
    }

    // MARK: Initializers

    init(inputURL: URL, outputURL: URL) {
        self.inputURL = inputURL
        self.outputURL = outputURL
    }

    // MARK: Processing

    func process(_ completionHandler: @escaping (_ exportSession: AVAssetExportSession?) -> Void) {
        let composition = AVMutableComposition()
        let asset = AVURLAsset(url: inputURL)

        // MARK: Video Track

        guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            completionHandler(nil)
            return
        }

        // MARK: CompositionVideoTrack

        guard let compositionVideoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)) else {
            completionHandler(nil)
            return
        }

        // MARK: TimeRange

        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)

        // MARK: Insert timerange to CompositionVideoTrack

        do {
            try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            completionHandler(nil)
            return
        }

        // MARK: Check audio video and add to AVComposition

        if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            do {
                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: CMTime.zero)
            } catch {
                completionHandler(nil)
                return
            }
        }

        let overlayLayer = CALayer()
        let videoLayer = CALayer()

        // MARK: Check video portrait and transform

        let videoTrackTransform = compositionVideoTrack.preferredTransform
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        var naturalSize: CGSize = .zero
        if isPortrait(videoTrackTransform) {
            naturalSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            let videoTransform = CGAffineTransform(rotationAngle: .pi / 2).concatenating(CGAffineTransform(translationX: naturalSize.width, y: 0))
            layerInstruction.setTransform(videoTransform, at: .zero)
        } else {
            naturalSize = videoTrack.naturalSize
            layerInstruction.setTransform(videoTrackTransform, at: .zero)
        }

        overlayLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)

        overlayLayer.addSublayer(videoLayer)

        overlays.forEach { overlay in
            let layer = overlay.layer
            layer.add(overlay.startAnimation, forKey: "startAnimation")
            layer.add(overlay.endAnimation, forKey: "endAnimation")
            overlayLayer.addSublayer(layer)
        }

        print("naturalSize: ", naturalSize)
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = naturalSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: overlayLayer)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
        _ = composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack

        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: outputPresetName) else {
            completionHandler(nil)
            return
        }

        // MARK: Progress export

        exportProgressBarTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Get Progress
            let progress = Float(exportSession.progress)
            self.progress = progress
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously { () in
            self.exportProgressBarTimer.invalidate()
            completionHandler(exportSession)
        }
    }

    func addOverlay(_ overlay: BaseOverlay) {
        overlays.append(overlay)
    }
}

extension VideoOverlayProcessor {
    func isPortrait(_ videoTrackTransform: CGAffineTransform) -> Bool {
        if videoTrackTransform.a == 0 && videoTrackTransform.b == 1.0 && videoTrackTransform.c == -1.0 && videoTrackTransform.d == 0 {
            return true
        } else if videoTrackTransform.a == 0 && videoTrackTransform.b == -1.0 && videoTrackTransform.c == 1.0 && videoTrackTransform.d == 0 {
            return true
        } else {
            return false
        }
    }
}
