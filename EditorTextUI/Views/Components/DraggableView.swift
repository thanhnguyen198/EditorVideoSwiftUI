
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
    @State var width: CGFloat?
    @State var height: CGFloat?

    var content: () -> Content
    var onEnd: (_ size: CGSize, _ position: CGSize) -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content()
                .offset(x: position.width + dragState.translation.width, y: position.height + dragState.translation.height)
                .opacity(dragState.isPressing ? 0.5 : 1.0)
                .frame(width: width, height: height)
                .gesture(
                    LongPressGesture(minimumDuration: 0.2)
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
                            guard let width = width, let height = height else {
                                onEnd(.zero, position)
                                return
                            }
                            onEnd(.init(width: width, height: height), position)
                        })
                )

//            Color.red
//                .offset(x: position.width + dragState.translation.width, y: position.height + dragState.translation.height)
//                .frame(width: 40, height: 40)
//                .gesture(
//                    DragGesture(minimumDistance: 10)
//                        .onChanged({ value in
//                            guard let width = width, let height = height else {
//                                return
//                            }
//                            let transaltionSize = value.translation
//                            self.width = max(100, width + transaltionSize.width)
//                            self.height = max(100, height + transaltionSize.height)
//                            onEnd(.init(width: width, height: height), position)
//                        })
//                )
        }
    }
}
