//
//  NavigationBar.swift
//  SwiftUITemplate
//
//  Created by apple on 17/04/2023.
//

import Foundation
import SwiftUI

struct NavigationBar<Leading, Middle, Trailing>: View where Leading: View, Middle: View, Trailing: View {
    var leading: () -> Leading
    var middle: () -> Middle
    var trailing: () -> Trailing
    var backgroundColor: Color
    init(@ViewBuilder leading: @escaping () -> Leading,
         @ViewBuilder middle: @escaping () -> Middle,
         @ViewBuilder trailing: @escaping () -> Trailing,
         padding: CGFloat = 18, backgroundColor: Color = .white) {
        self.leading = leading
        self.middle = middle
        self.trailing = trailing
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            backgroundColor
            VStack {
                ZStack {
                    HStack {
                        leading()
                        Spacer()
                        trailing()
                    }
                    middle()
                }
                .padding(.horizontal, 12)
                .foregroundColor(.black)
            }
        }
        .frame(width: kScreen.bounds.width, height: Constant.NavigationBar.height)
        .background(backgroundColor)
    }
}
