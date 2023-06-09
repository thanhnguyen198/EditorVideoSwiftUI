//
//  ButtonEditorText.swift
//  EditorTextUI
//
//  Created by kii on 07/06/2023.
//

import SwiftUI

struct ButtonEditorText<Content>: View where Content: View {
    var title: String = ""
    var content: () -> Content
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Color.darkGray
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        content
                    )
            }
            if !title.isEmpty {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .bold()
            }
        }
    }
}

struct ButtonEditorText_Previews: PreviewProvider {
    static var previews: some View {
        ButtonEditorText(content: {
            EmptyView()
        })
    }
}
