import Combine
import Foundation

class ___VARIABLE_productName___ViewModel: ObservableObject {
    enum RouteView {
    }

    private var cancellables = Set<AnyCancellable>()
    private let route = PassthroughSubject<RouteView, Never>()
    let action = PassthroughSubject<ActionView, Never>()

    init() {
        binding()
    }

    private func binding() {
    }
}

extension ___VARIABLE_productName___ViewModel {
    enum ActionView {
    }
}
