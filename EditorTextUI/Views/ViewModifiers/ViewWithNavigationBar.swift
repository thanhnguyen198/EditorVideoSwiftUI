//
//  ViewWithNavigationBar.swift
//  iosApp
//
//  Created by apple on 23/11/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI

struct ViewWithNavigationBar<Leading, Middle, Trailing>: ViewModifier where Leading: View, Middle: View, Trailing: View {
    var leading: () -> Leading
    var middle: () -> Middle
    var trailing: () -> Trailing
    var backgroundColor: Color

    init(@ViewBuilder leading: @escaping () -> Leading,
         @ViewBuilder middle: @escaping () -> Middle,
         @ViewBuilder trailing: @escaping () -> Trailing, backgroundColor: Color = .white) {
        self.leading = leading
        self.middle = middle
        self.trailing = trailing
        self.backgroundColor = backgroundColor
    }

    func body(content: Content) -> some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                content
                    .padding(.top, Constant.NavigationBar.height)
                    .navigationBarHidden(true)
                    .navigationBarSafeAreaColor(backgroundColor: backgroundColor)
                NavigationBar(leading: leading, middle: middle, trailing: trailing, backgroundColor: backgroundColor)
            }
        }
    }
}

struct NavigationBarSafeAreaModifier: ViewModifier {
    var backgroundColor: UIColor = .white

    init(backgroundColor: Color) {
        self.backgroundColor = UIColor(backgroundColor)

        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = UIColor(backgroundColor)
        coloredAppearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {
    func navigationBarSafeAreaColor(backgroundColor: Color) -> some View {
        modifier(NavigationBarSafeAreaModifier(backgroundColor: backgroundColor))
    }
}
