//
//  KeyboardAdaptive.swift
//  iosApp
//
//  Created by apple on 29/11/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import Combine
import SwiftUI

struct KeyboardAdaptive: ViewModifier {
    @Binding var isShowKeyboard: Bool
    @State private var keyboardHeight: CGFloat = 0
    func body(content: Content) -> some View {
        VStack(spacing: 0.5) {
            content

            if keyboardHeight != 0 {
                Spacer()
                    .frame(height: keyboardHeight)
                    .animation(.spring())
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(Publishers.keyboardHeight) { keyboardHeight in
            let keyboardTop = kScreenSize.height - keyboardHeight
            let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
            self.keyboardHeight = focusedTextInputBottom - keyboardTop > 0 ? keyboardHeight : 0
            isShowKeyboard = keyboardHeight != 0
        }
        .background(Color.clear)
    }
}

extension UIResponder {
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    private weak static var _currentFirstResponder: UIResponder?

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}

extension View {
    func keyboardAdaptive(isShowKeyboard: Binding<Bool>) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive(isShowKeyboard: isShowKeyboard))
    }
}
