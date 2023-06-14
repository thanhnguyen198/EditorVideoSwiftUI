import _AVKit_SwiftUI
import Combine
import Foundation
import SwiftUI

struct EditorVideoView: View {
    @StateObject var viewModel: EditorVideoViewModel
    @State var position: CGSize = .zero
    @State var showPickerVideo: Bool = false
    @State var width: Double = 250
    @State var height: Double = 400
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
                            .frame(width: kScreenSize.width)
                    }

                    DraggableView(position: $viewModel.positionText) {
                        ZStack {
//                            if let textOv = viewModel.textProp {
//                                Text(textOv.text)
//                                    .foregroundColor(textOv.color)
//                                    .font(.system(size: textOv.fontSize))
//                                    .multilineTextAlignment(textOv.alignment)
//                                    .frame(minWidth: 0, maxWidth: .infinity)
//                                    .readSize { size in
//                                        viewModel.sizeText = size
//                                    }
//                            } else {
//                                EmptyView()
//                            }

                            if let subVideo = viewModel.subVideoURL {
                                ZStack(alignment: .bottomTrailing) {
                                    PlayerView(player: .init(url: subVideo), videpGravity: .resize)
                                        .clipped()
                                        .frame(width: width, height: height)
                                        .overlay(.blue.opacity(0.3))
                                        .id(subVideo.url.absoluteString)
                                        .readSize { size in
                                            viewModel.sizeSubVideo = size
                                        }
                                    Color.red
                                        .frame(width: 40, height: 40)
                                        .gesture(
                                            DragGesture()
                                                .onChanged({ value in
                                                    width = max(100, width + value.translation.width)
                                                    height = max(100, height + value.translation.height)

                                                })
                                        )
                                }
                                .frame(width: width, height: height, alignment: .center)
                                .border(.red, width: 5)
                                .background(.yellow)
                            }
                        }
                    }
                }
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
