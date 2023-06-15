import _AVKit_SwiftUI
import Combine
import Foundation
import SwiftUI

struct EditorVideoView: View {
    @StateObject var viewModel: EditorVideoViewModel
    @State var position: CGSize = .zero
    @State var showPickerVideo: Bool = false
    @State var width: Double = 150
    @State var height: Double = 150
    let router: EditorVideoRouter

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    GeometryReader { proxy in
                        PlayerView(player: viewModel.avPlayer)
                            .onAppear {
                                viewModel.geoVideo = proxy.size
                            }
                    }
                    // Text
                    DraggableView {
                        ZStack {
                            if let textOv = viewModel.textProp {
                                Text(textOv.text)
                                    .foregroundColor(textOv.color)
                                    .font(.system(size: textOv.fontSize))
                                    .multilineTextAlignment(textOv.alignment)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .readSize { size in
                                        viewModel.sizeText = size
                                    }
                            } else {
                                EmptyView()
                            }
                        }
                    } onEnd: { _, position in
                        viewModel.positionText = position
                    }
                    // Video
                    DraggableView(width: width, height: height) {
                        ZStack {
                            if let subVideo = viewModel.subVideoURL {
                                PlayerView(player: .init(url: subVideo), videoGravity: .resize)
                                    .clipped()
                                    .id(subVideo.url.absoluteString)
                            } else {
                                EmptyView()
                            }
                        }
                    } onEnd: { size, position in
                        viewModel.positionSubVideo = position
                        viewModel.sizeSubVideo = size
                    }

                    DraggableView {
                        Assets._4k
                            .resizable()
                            .frame(width: 150, height: 150)
                            .readSize { size in
                                viewModel.sizeImage = size
                            }
                    } onEnd: { _, position in
                        viewModel.positionImage = position
                    }
                }
                .frame(width: kScreenSize.width, height: kScreenSize.height / 2)

                Spacer()

                HStack {
                    ButtonEditorText(title: "Text") {
                        Image(systemName: "character")
                            .foregroundColor(.white)
                            .font(.system(size: 12), weight: .bold)
                            .scaleEffect(1.4)
                    }
                    .onPress {
                        router.trigger(.addTextOverlay({ textOverlay in
                            position = .zero
                            viewModel.textProp = textOverlay
                        }))
                    }
                    ButtonEditorText(title: "Sub Video") {
                        Image(systemName: "video")
                            .foregroundColor(.white)
                            .font(.system(size: 12), weight: .bold)
                            .scaleEffect(1.4)
                    }
                    .onPress {
                        showPickerVideo.toggle()
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
            }
            if viewModel.isExporting {
                LoadingView(progress: viewModel.progress)
            }
        }
        .sheet(isPresented: $showPickerVideo, content: {
            VideoPicker(url: $viewModel.subVideoURL)
        })
        .navigationBar(leading: {
            Text("Cancel")
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(Capsule())
                .onPress {
                    AppState.shared.actionCancel.send()
                }
        }, middle: {
        }, trailing: {
            Text("Save")
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(Capsule())
                .onPress {
                    viewModel.saveVideo()
                }
        }, backgroundColor: .clear)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
