import Combine
import Coordinator
import Foundation

class EditorVideoRouter: UIViewControllerCoordinator<EditorVideoRouter.Screen> {
    enum Screen {
        case addTextOverlay((TextProp) -> Void)
    }

    override func transition(for route: Screen) -> ViewTransition {
        switch route {
        case let .addTextOverlay(action):
            return .custom {
                self.rootViewController?.present(background: .black.withAlphaComponent(0.3), builder: {
                    AddTextOverlayView(doneAction: action)
                })
            }
        }
    }
}
