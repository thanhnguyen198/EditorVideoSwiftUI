//
//  ViewShadow.swift
//  iosApp
//
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct ShadowBlack20: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.2), radius: 4, y: 1)
    }
}

extension View {
    func shadowBlack20() -> some View {
        modifier(ShadowBlack20())
    }
}
