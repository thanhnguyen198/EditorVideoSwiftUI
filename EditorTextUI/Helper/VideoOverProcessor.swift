//
//  VideoOverProcessor.swift
//  AddTextSwiftUI
//
//  Created by kii on 06/06/2023.
//

import AVFoundation
import Photos
import UIKit

class VideoOverlayProcessor: ObservableObject {
    let inputURL: URL
    let outputURL: URL

    var exportProgressBarTimer = Timer() // initialize timer
    var outputPresetName: String = AVAssetExportPresetHEVC1920x1080
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
        let mainComposition = AVMutableComposition()
        let mainVideo = AVURLAsset(url: inputURL)

        // MARK: Video Track

        guard let videoTrack = mainVideo.tracks(withMediaType: AVMediaType.video).first else {
            completionHandler(nil)
            return
        }

        // MARK: CompositionVideoTrack

        guard let compositionVideoTrack: AVMutableCompositionTrack = mainComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)) else {
            completionHandler(nil)
            return
        }

        // MARK: TimeRange

        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mainVideo.duration)

        // MARK: Insert timerange to CompositionVideoTrack

        do {
            try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            completionHandler(nil)
            return
        }

        // MARK: Check audio video and add to AVComposition

        if let audioTrack = mainVideo.tracks(withMediaType: AVMediaType.audio).first {
            let compositionAudioTrack = mainComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
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

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        let videoTrackTransform = compositionVideoTrack.preferredTransform
        let naturalSize: CGSize = videoSize
        if isPortrait(videoTrackTransform) {
            let videoTransform = CGAffineTransform(rotationAngle: .pi / 2)
                .concatenating(CGAffineTransform(translationX: naturalSize.width, y: 0))
            layerInstruction.setTransform(videoTransform, at: .zero)
        } else {
            layerInstruction.setTransform(videoTrackTransform, at: .zero)
        }

        overlayLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        overlayLayer.addSublayer(videoLayer)

        for overlay in overlays.filter({ $0 is TextOverlay || $0 is ImageOverlay }) {
            let layer = overlay.layer
            layer.add(overlay.startAnimation, forKey: "startAnimation")
            layer.add(overlay.endAnimation, forKey: "endAnimation")
            overlayLayer.addSublayer(layer)
        }

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = naturalSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: overlayLayer)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: mainComposition.duration)
        _ = mainComposition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack

        // TODO: Adding video to video
        var subInstructions: [AVMutableVideoCompositionLayerInstruction] = []

        for overlay in overlays {
            if let overlayVideo = overlay as? VideoOverlay {
                let avAsset = AVURLAsset(url: overlayVideo.url)
                guard let videoTrack = avAsset.tracks(withMediaType: .video).first,
                      let audioTrack = avAsset.tracks(withMediaType: .audio).first,
                      let overlayVideoTrackComposition = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)),
                      let overlayAudioTrackComposition = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
                else { return }

                do {
                    let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mainVideo.duration)
                    try overlayVideoTrackComposition.insertTimeRange(timeRange,
                                                                     of: videoTrack,
                                                                     at: .zero)
                    try overlayAudioTrackComposition.insertTimeRange(timeRange,
                                                                     of: audioTrack,
                                                                     at: .zero)
                } catch {
                    print("Failed to load first track")
                    return
                }
                let instructionSubVideo = AVMutableVideoCompositionLayerInstruction(assetTrack: overlayVideoTrackComposition)
                let overlayStartTime = CMTime(seconds: overlay.delay, preferredTimescale: 600)
                let durationTime = CMTime(seconds: overlay.duration, preferredTimescale: 600)
                instructionSubVideo.setOpacity(0, at: .zero)
                instructionSubVideo.setOpacity(1, at: overlayStartTime)
                instructionSubVideo.setOpacity(0, at: durationTime)

                let frame = overlay.frame
                let subNaturalSize: CGSize = overlayVideoTrackComposition.naturalSize

                if isPortrait(videoTrack.preferredTransform) {
                    let ratioW = frame.width / subNaturalSize.height
                    let ratioH = frame.height / subNaturalSize.width
                    let rotation = CGAffineTransform(rotationAngle: .pi / 2)
                        .concatenating(CGAffineTransform(translationX: subNaturalSize.width, y: 0))
                    let transform = CGAffineTransform(scaleX: ratioW, y: ratioH)
                        .concatenating(CGAffineTransform(translationX: naturalSize.width - frame.origin.x - (subNaturalSize.width * ratioW),
                                                         y: frame.origin.y))
                    instructionSubVideo.setTransform(rotation.concatenating(transform), at: .zero)
                } else {
                    let ratioW = frame.width / subNaturalSize.width
                    let ratioH = frame.height / subNaturalSize.height
                    let transform = CGAffineTransform(scaleX: ratioW, y: ratioH)
                        .concatenating(CGAffineTransform(translationX: frame.origin.x,
                                                         y: naturalSize.height - frame.origin.y - (subNaturalSize.height * ratioH)))
                    instructionSubVideo.setTransform(transform, at: .zero)
                }
                subInstructions.append(instructionSubVideo)
            }
        }

        instruction.layerInstructions.append(contentsOf: subInstructions)
        instruction.layerInstructions.append(layerInstruction)
        videoComposition.instructions = [instruction]

        guard let exportSession = AVAssetExportSession(asset: mainComposition, presetName: outputPresetName) else {
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
        exportSession.outputFileType = AVFileType.mp4
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

extension FileManager {
    func removeItemIfExisted(_ url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            } catch {
                print("Failed to delete file")
            }
        }
    }
}
