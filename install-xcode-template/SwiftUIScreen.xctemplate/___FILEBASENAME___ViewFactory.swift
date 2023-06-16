import Combine
import Foundation
import SwiftUI

struct ___VARIABLE_productName___ViewFactory: View {
    var body: some View {
        let router = ___VARIABLE_productName___Router()
        let viewModel = ___VARIABLE_productName___ViewModel()
        return ___VARIABLE_productName___View(viewModel: viewModel, router: router).coordinator(router)
    }
}
