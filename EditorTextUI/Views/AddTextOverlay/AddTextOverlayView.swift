//
//  AddTextOverlayView.swift
//  EditorTextUI
//
//  Created by kii on 07/06/2023.
//

import SwiftUI

struct TextProp: Equatable {
    var id: UUID = UUID()
    var text: String
    var color: Color
    var alignment: TextAlignment
    var fontSize: CGFloat
    var offSet: CGSize = .zero
}

struct AddTextOverlayView: View {
    enum Field: Hashable {
        case textField
    }

    let doneAction: (TextProp) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State var text: String = ""
    @State var color: Color = .white
    @State var alignment: (before: TextAlignment, current: TextAlignment) = (.leading, .center)
    @State var sliderFontSize: CGFloat = 16
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack {
                Spacer()
                TextField("Enter text ...", text: $text)
                    .foregroundColor(color)
                    .font(.system(size: sliderFontSize))
                    .multilineTextAlignment(alignment.current)
                    .focused($focusedField, equals: .textField)
                Spacer()
                Slider(value: $sliderFontSize, in: 12 ... 100)
                HStack {
                    ButtonEditorText {
                        color.frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .overlay(ColorPicker("", selection: $color).labelsHidden().opacity(0.015))
                    }

                    Spacer()
                }
                .padding(.bottom, 12)
            }
        }
        .padding(.horizontal, 12)
        .navigationBar(leading: {
            Text("Cancel")
                .foregroundColor(.white)
                .onPress {
                    presentationMode.dismiss()
                }
        }, middle: {
            Text("\(250 - text.count)")
                .bold()
                .foregroundColor(.white)
        }, trailing: {
            Text("Done")
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .onPress {
                    presentationMode.dismiss()
                    let textOverlay = TextProp(text: text, color: color, alignment: alignment.current, fontSize: sliderFontSize)
                    doneAction(textOverlay)
                }
        }, backgroundColor: .clear)
    }
}
