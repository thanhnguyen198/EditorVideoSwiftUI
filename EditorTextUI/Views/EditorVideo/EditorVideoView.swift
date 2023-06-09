import _PhotosUI_SwiftUI
import Combine
import Foundation
import SwiftUI

struct EditorVideoView: View {
    @StateObject var viewModel: EditorVideoViewModel
    @State var photoItem: PhotosPickerItem?
    @State var position: CGSize = .zero
    let router: EditorVideoRouter

    var body: some View {
        VStack {
            ZStack {
                GeometryReader { proxy in
                    PlayerView(player: viewModel.avPlayer)
                        .onAppear {
                            viewModel.avPlayer.play()
                            viewModel.geoVideo = proxy.size
                        }
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
                        .bold()
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
        .navigationBar(leading: {
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
