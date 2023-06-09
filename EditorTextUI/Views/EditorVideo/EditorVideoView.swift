import _AVKit_SwiftUI
import Combine
import Foundation
import SwiftUI

struct EditorVideoView: View {
    @StateObject var viewModel: EditorVideoViewModel
    @State var position: CGSize = .zero
    let router: EditorVideoRouter

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    GeometryReader { proxy in
                        PlayerView(player: viewModel.avPlayer)
//                        VideoPlayer(player: viewModel.avPlayer)
//                            .disabled(true)
                            .onAppear {
                                viewModel.avPlayer.play()
                                viewModel.geoVideo = proxy.size
                            }
                            .frame(width: kScreenSize.width)
                    }

                    DraggableView(position: $viewModel.positionText) {
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
                    Spacer()
                }
                .padding(.horizontal, 12)
            }
            if viewModel.isExporting {
                LoadingView(progress: viewModel.progress)
            }
        }

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
