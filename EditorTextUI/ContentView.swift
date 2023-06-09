//
//  ContentView.swift
//  EditorTextUI
//
//  Created by kii on 07/06/2023.
//

import Combine
import PhotosUI
import SwiftUI
class AppState: ObservableObject {
    static var shared = AppState()
    var actionCancel = PassthroughSubject<Void, Never>()
}

struct ContentView: View {
    @State var showPicker: Bool = false
    @State var url: URL?

    var body: some View {
        Group {
            if let url = url {
                EditorVideoViewFactory(url: url)
            } else {
                Button {
                    showPicker.toggle()
                } label: {
                    Text("Pick video")
                }
            }
        }
        .sheet(isPresented: $showPicker, content: {
            VideoPicker(url: $url)
        })
        .animation(.spring(), value: url)
        .onReceive(AppState.shared.actionCancel) { _ in
            url = nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
