import _AVKit_SwiftUI
import Combine
import Foundation
import SwiftUI

struct EditorVideoView: View {
    @StateObject var viewModel: EditorVideoViewModel
    @State var position: CGSize = .zero
    @State var showPickerVideo: Bool = false
    @State var showPickerImage: Bool = false
    let router: EditorVideoRouter

    var body: some View {
        ZStack {
            VStack {
                // Video + edit with component
                ZStack {
                    GeometryReader { proxy in
                        PlayerView(player: viewModel.avPlayer)
                            .onAppear {
                                viewModel.geoVideo = proxy.size
                            }
                    }
                    // Text
                    DraggableView(isMedia: false) {
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
                    } onEnd: { position in
                        viewModel.positionText = position
                    }
                    // Video
                    DraggableView {
                        ZStack {
                            if let subVideo = viewModel.subVideoURL {
                                PlayerView(player: .init(url: subVideo), videoGravity: .resize)
                                    .frame(width: 150, height: 150)
                                    .clipped()
                                    .id(subVideo.url.absoluteString)
                                    .readSize { size in
                                        viewModel.sizeSubVideo = size
                                    }
                            } else {
                                EmptyView()
                            }
                        }
                    } onEnd: { position in
                        viewModel.positionSubVideo = position
                    }
                    // Image
                    DraggableView {
                        ZStack {
                            if let image = viewModel.imageOverlay {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .readSize { size in
                                        viewModel.sizeImage = size
                                    }
                            }
                        }

                    } onEnd: { position in
                        viewModel.positionImage = position
                    }
                }
                .frame(width: kScreenSize.width, height: kScreenSize.height / 2)

                Spacer()

                // Toolbar
                toolBarEditor
            }
            if viewModel.isExporting {
                LoadingView(progress: viewModel.progress)
            }
        }
        .padding(.top, 12)
        .sheet(isPresented: $showPickerImage, content: {
            ImagePicker(selectedImage: $viewModel.imageOverlay)
        })
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

    var toolBarEditor: some View {
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
            ButtonEditorText(title: "Image") {
                Image(systemName: "photo")
                    .foregroundColor(.white)
                    .font(.system(size: 12), weight: .bold)
                    .scaleEffect(1.4)
            }
            .onPress {
                showPickerImage.toggle()
            }
            Spacer()
        }
        .padding(.horizontal, 12)
    }
}
