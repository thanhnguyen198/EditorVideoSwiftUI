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
    var outputPresetName: String = AVAssetExportPresetHighestQuality
    @Published var progress: Float = 0.0

    private var overlays: [BaseOverlay] = []

    var videoSize: CGSize {
        let asset = AVURLAsset(url: inputURL)
        let track = asset.tracks(withMediaType: AVMediaType.video).first
        if let track = track, isPortrait(track.preferredTransform) {
            return .init(width: 1080, height: 1964)
        } else {
            return .init(width: 1964, height: 1080)
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
            let scale = max(naturalSize.width / videoTrack.naturalSize.height,
                            naturalSize.height / videoTrack.naturalSize.width)
            let videoTransform = CGAffineTransform(rotationAngle: .pi / 2)
                .concatenating(CGAffineTransform(translationX: naturalSize.width, y: 0))
            layerInstruction.setTransform(videoTransform.scaledBy(x: scale, y: scale), at: .zero)
        } else {
            let scale = max(naturalSize.width / videoTrack.naturalSize.width,
                            naturalSize.height / videoTrack.naturalSize.height)
            layerInstruction.setTransform(videoTrackTransform.concatenating(CGAffineTransform(scaleX: scale, y: scale)), at: .zero)
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
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mainComposition.duration)
        _ = mainComposition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack

        // TODO: Adding video to video
        var subInstructions: [AVMutableVideoCompositionLayerInstruction] = []

        for overlay in overlays {
            if let overlayVideo = overlay as? VideoOverlay {
                let avAsset = AVURLAsset(url: overlayVideo.url)
                guard let videoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)),
                      let audioTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
                else { return }

                do {
                    let timeRange = overlay.timeRange
                    try videoTrack.insertTimeRange(timeRange,
                                                   of: avAsset.tracks(withMediaType: .video)[0],
                                                   at: .zero)
                    try audioTrack.insertTimeRange(timeRange,
                                                   of: avAsset.tracks(withMediaType: .audio)[0],
                                                   at: .zero)
                } catch {
                    print("Failed to load first track")
                    return
                }
                let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                let frame = overlay.frame
                let subNaturalSize: CGSize = videoTrack.naturalSize

                let ratioW = frame.width / subNaturalSize.width
                let ratioH = frame.height / subNaturalSize.height

                let transform = CGAffineTransform(scaleX: ratioW, y: ratioH)
                    .concatenating(CGAffineTransform(translationX: frame.origin.x,
                                                     y: naturalSize.height - frame.origin.y - (subNaturalSize.height * ratioH)))

                instruction.setTransform(transform, at: CMTime.zero)

                subInstructions.append(instruction)
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

    func newoverlay(video firstAsset: AVURLAsset, withSecondVideo secondAsset: AVURLAsset, _ completionHandler: @escaping (_ exportSession: AVAssetExportSession?) -> Void) {
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()

        // 2 - Create two video tracks
        guard let firstTrack = mixComposition.addMutableTrack(withMediaType: .video,
                                                              preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: firstAsset.duration),
                                           of: firstAsset.tracks(withMediaType: .video)[0],
                                           at: CMTime.zero)
        } catch {
            print("Failed to load first track")
            return
        }

        guard let secondTrack = mixComposition.addMutableTrack(withMediaType: .video,
                                                               preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        do {
            try secondTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: secondAsset.duration),
                                            of: secondAsset.tracks(withMediaType: .video)[0],
                                            at: CMTime.zero)
        } catch {
            print("Failed to load second track")
            return
        }

        // 2.1
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeAdd(firstAsset.duration, secondAsset.duration))

        // 2.2
        let firstInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)

        let secondInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondTrack)
        let scale = CGAffineTransform(scaleX: 0.3, y: 0.3)
        let move = CGAffineTransform(translationX: 10, y: 10)
        secondInstruction.setTransform(scale.concatenating(move), at: CMTime.zero)
        // 2.3
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

//        let width = max(firstTrack.naturalSize.width, secondTrack.naturalSize.width)
//        let height = max(firstTrack.naturalSize.height, secondTrack.naturalSize.height)

        mainComposition.renderSize = CGSize(width: videoSize.width, height: videoSize.height)

        mainInstruction.backgroundColor = UIColor.clear.cgColor

        // 4 - Get path
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")

        // Check exists and remove old file
        FileManager.default.removeItemIfExisted(url as URL)

        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition

        // 6 - Perform the Export
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                print("Movie complete")
                completionHandler(exporter)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url as URL)
                }) { saved, _ in
                    if saved {
                        print("Saved")
                    }
                }
            }
        }
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
