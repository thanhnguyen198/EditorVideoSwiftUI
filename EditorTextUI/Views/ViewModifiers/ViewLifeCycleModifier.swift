//
//  ViewWillDisappearModifier.swift
//  iosApp
//
//  Created by Trung Hoang on 22/12/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI

struct ViewLifeCycleHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> ViewLifeCycleHandler.Coordinator {
        Coordinator(onWillDisappear: onWillDisappear, onWillAppear: onWillAppear, onDidAppear: onDidAppear, onDidDisappear: onDidDisappear)
    }

    let onWillDisappear: (() -> Void)?
    let onWillAppear: (() -> Void)?
    let onDidAppear: (() -> Void)?
    let onDidDisappear: (() -> Void)?

    init(onWillDisappear: (() -> Void)? = nil, onWillAppear: (() -> Void)? = nil, onDidAppear: (() -> Void)? = nil, onDidDisappear: (() -> Void)? = nil) {
        self.onWillDisappear = onWillDisappear
        self.onWillAppear = onWillAppear
        self.onDidAppear = onDidAppear
        self.onDidDisappear = onDidDisappear
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewLifeCycleHandler>) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ViewLifeCycleHandler>) {
    }

    typealias UIViewControllerType = UIViewController

    class Coordinator: UIViewController {
        let onWillDisappear: (() -> Void)?
        let onWillAppear: (() -> Void)?
        let onDidAppear: (() -> Void)?
        let onDidDisappear: (() -> Void)?

        init(onWillDisappear: (() -> Void)? = nil, onWillAppear: (() -> Void)? = nil, onDidAppear: (() -> Void)? = nil, onDidDisappear: (() -> Void)? = nil) {
            self.onWillDisappear = onWillDisappear
            self.onWillAppear = onWillAppear
            self.onDidAppear = onDidAppear
            self.onDidDisappear = onDidDisappear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear?()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            onWillAppear?()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            onDidAppear?()
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            onDidDisappear?()
        }
    }

    struct Modifier: ViewModifier {
        let onWillDisappear: (() -> Void)?
        let onWillAppear: (() -> Void)?
        let onDidAppear: (() -> Void)?
        let onDidDisappear: (() -> Void)?

        init(onWillDisappear: (() -> Void)? = nil, onWillAppear: (() -> Void)? = nil, onDidAppear: (() -> Void)? = nil, onDidDisappear: (() -> Void)? = nil) {
            self.onWillDisappear = onWillDisappear
            self.onWillAppear = onWillAppear
            self.onDidAppear = onDidAppear
            self.onDidDisappear = onDidDisappear
        }

        func body(content: Content) -> some View {
            content
                .background(ViewLifeCycleHandler(onWillDisappear: onWillDisappear, onWillAppear: onWillAppear, onDidAppear: onDidAppear, onDidDisappear: onDidDisappear))
        }
    }
}

extension View {
    func viewLifeCycle(onWillAppear: (() -> Void)? = nil, onWillDisappear: (() -> Void)? = nil, onDidAppear: (() -> Void)? = nil, onDidDisappear: (() -> Void)? = nil) -> some View {
        modifier(ViewLifeCycleHandler.Modifier(onWillDisappear: onWillDisappear, onWillAppear: onWillAppear, onDidAppear: onDidAppear, onDidDisappear: onDidDisappear))
    }
}
