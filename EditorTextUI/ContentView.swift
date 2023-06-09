//
//  ContentView.swift
//  EditorTextUI
//
//  Created by kii on 07/06/2023.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    @State var photoItem: PhotosPickerItem?
    @State var url: URL?
    var body: some View {
        Group {
            if let url = url {
                EditorVideoViewFactory(url: url)
            } else {
                PhotosPicker("Pick video", selection: $photoItem, matching: .any(of: [.videos]))
                    .onChange(of: photoItem) { _ in
                        if let photoItem = photoItem {
                            photoItem.loadTransferable(type: Video.self) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case let .success(video):
                                        self.url = video?.url
                                    case let .failure(error):
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
            }
        }
        .animation(.default, value: url)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
