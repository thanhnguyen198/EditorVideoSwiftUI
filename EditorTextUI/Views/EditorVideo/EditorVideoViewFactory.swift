import Combine
import Foundation
import SwiftUI

struct EditorVideoViewFactory: View {
    let url: URL
    var body: some View {
        let router = EditorVideoRouter()
        let viewModel = EditorVideoViewModel(url:url)
        return EditorVideoView(viewModel: viewModel, router: router).coordinator(router)
    }
}
