import AVFoundation
import Combine
import Foundation
import Photos
import UIKit

class EditorVideoViewModel: ObservableObject {
    enum RouteView {
    }

    private var cancellables = Set<AnyCancellable>()
    private let route = PassthroughSubject<RouteView, Never>()
    let action = PassthroughSubject<ActionView, Never>()
    let url: URL
    @Published var avPlayer = AVPlayer()
    @Published var textProp: TextProp?
    @Published var positionText: CGSize = .zero
    @Published var sizeText: CGSize = .zero
    @Published var geoVideo: CGSize = .zero
    @Published var isExporting: Bool = false
    @Published var progress: Float = 0.0
    init(url: URL) {
        self.url = url
        print("Player with url:", url)
        avPlayer = .init(playerItem: .init(url: url))
        binding()
    }

    private func binding() {
    }

    func saveVideo() {
        guard let textProp = textProp else { return }
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output-\(Int(Date().timeIntervalSince1970)).mov")

        let processor = VideoOverlayProcessor(inputURL: url, outputURL: outputURL)

        let videoSize = processor.videoSize

        let videoDuration = processor.videoDuration

        let position = convertSize(positionText, sizeText: sizeText, fromFrame: geoVideo, toFrame: videoSize)

        let textOverlay = TextOverlay(text: textProp.text,
                                      frame: CGRect(x: position.size.width, y: position.size.height, width: sizeText.width * position.ratio, height: sizeText.height * position.ratio),
                                      delay: 0.0,
                                      duration: videoDuration,
                                      backgroundColor: .clear,
                                      textColor: UIColor(textProp.color),
                                      font: .systemFont(ofSize: textProp.fontSize),
                                      textAlignment: .center,
                                      fontSize: textProp.fontSize * position.ratio)
        processor.addOverlay(textOverlay)
        isExporting = true
        processor.$progress.assign(to: &$progress)
        processor.process { [weak self] exportSession in
            guard let self = self else { return }
            guard let exportSession = exportSession else { return }
            DispatchQueue.main.async {
                self.isExporting = false
            }
            if exportSession.status == .completed {
                DispatchQueue.main.async {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                    }) { success, error in
                        if success {
                            print("Export library success")
                        } else {
                            print("Export library error", error)
                        }
                    }
                }
            }
        }
    }

    func convertSize(_ size: CGSize, sizeText: CGSize, fromFrame frameSize1: CGSize, toFrame frameSize2: CGSize) -> (size: CGSize, ratio: Double) {
        let widthRatio = frameSize2.width / frameSize1.width
        let heightRatio = frameSize2.height / frameSize1.height
        let ratio = max(widthRatio, heightRatio)
        let newSizeWidth = size.width * ratio
        let newSizeHeight = size.height * ratio
        let newSize = CGSize(width: (frameSize2.width / 2 - (sizeText.width * ratio / 2)) + newSizeWidth,
                             height: (frameSize2.height / 2 - (sizeText.height * ratio / 2)) + -newSizeHeight)
        return (CGSize(width: newSize.width, height: newSize.height), ratio)
    }
}

extension EditorVideoViewModel {
    enum ActionView {
    }
}
