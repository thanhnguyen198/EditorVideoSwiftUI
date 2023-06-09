//
//  NetworkImage.swift
//  SwiftUITemplate
//
//  Created by apple on 30/03/2023.
//

import Kingfisher
import SwiftUI

struct NetworkImageView: View {
    var url: URL
    @ViewBuilder
    var body: some View {
        KFImage(url)
            .resizable()
            .placeholder {
                ZStack(alignment: .center) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .cancelOnDisappear(true)
            .scaledToFit()
    }
}
