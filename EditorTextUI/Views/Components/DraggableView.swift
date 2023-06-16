
//
//  DraggableView.swift
//  AddTextSwiftUI
//
//  Created by kii on 05/06/2023.
//

import SwiftUI

enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive, .pressing:
            return .zero
        case let .dragging(translation):
            return translation
        }
    }

    var isPressing: Bool {
        switch self {
        case .pressing, .dragging:
            return true
        case .inactive:
            return false
        }
    }
}

struct DraggableView<Content>: View where Content: View {
    @GestureState private var dragState = DragState.inactive
    @State var position: CGSize = .zero
    @State var scale: CGFloat = 1.0
    var isMedia: Bool = true
    var content: () -> Content
    var onEnd: (_ position: CGSize) -> Void

    var body: some View {
        let dragScaleGesture = DragGesture(minimumDistance: 10)
            .onChanged { value in
                if isMedia {
                    let width = value.translation.width
                    let height = value.translation.height
                    let min = min(width, height)
                    let max = max(width, height)
                    var translation: CGFloat = 0
                    if width <= 0 && height <= 0 {
                        translation = min
                    } else {
                        translation = max
                    }
                    scale *= 1.0 + translation / 10000
                }
            }
        ZStack(alignment: .bottomTrailing) {
            content()
                .offset(x: position.width + dragState.translation.width, y: position.height + dragState.translation.height)
                .opacity(dragState.isPressing ? 0.5 : 1.0)
                .scaleEffect(scale)
                .gesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .sequenced(before: DragGesture())
                        .updating($dragState, body: { value, state, _ in
                            switch value {
                            case .first(true):
                                state = .pressing
                            case .second(true, let drag):
                                state = .dragging(translation: drag?.translation ?? .zero)
                            default:
                                break
                            }
                        })
                        .onEnded({ value in
                            guard case .second(true, let drag?) = value else {
                                return
                            }
                            self.position.height += drag.translation.height
                            self.position.width += drag.translation.width
                            onEnd(position)
                        })
                )
//            Color.red
//                .offset(x: position.width + dragState.translation.width, y: position.height + dragState.translation.height)
//                .frame(width: 20, height: 20)
//                .gesture(dragScaleGesture)
        }
    }
}
