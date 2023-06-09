//
//  AdaptsToKeyboard.swift
//  iosApp
//
//  Created by Trung Hoang on 10/12/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import Combine
import SwiftUI

struct AdaptsToKeyboard: ViewModifier {
    @State var keyboardHeight: CGFloat = 0
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.keyboardHeight)
                .onAppear(perform: {
                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
                        .merge(with: NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification))
                        .compactMap { notification in
                            withAnimation(.easeOut(duration: 0.16)) {
                                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                            }
                        }
                        .map { rect in
                            rect.height - geometry.safeAreaInsets.bottom
                        }
                        .subscribe(Subscribers.Assign(object: self, keyPath: \.keyboardHeight))

                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
                        .compactMap { _ in
                                .zero
                        }
                        .subscribe(Subscribers.Assign(object: self, keyPath: \.keyboardHeight))
                })
        }
    }
}

extension View {
    func adaptsToKeyboard() -> some View {
        modifier(AdaptsToKeyboard())
    }
}
