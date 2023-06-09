//
//  LoadingView.swift
//  SwiftUITemplate
//
//  Created by apple on 04/04/2023.
//

import SwiftUI

import Combine

struct LoadingView: View {
    var progress: Float?
    var body: some View {
        ZStack {
            Color.black.opacity(0.2).blur(radius: 2)
            let progress = progress ?? 0
            VStack {
                Text("Loading...\(progress == 0 ? "" : "\(Int(progress * 100))%")")
                    .font(.title3)
                    .foregroundColor(.white)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
            .padding(24)
            .background(.lightGray.opacity(0.5))
            .cornerRadius(12)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

class LoadingViewObserver {
    static let shared = LoadingViewObserver()

    @Published var isLoading: Bool = false

    private var loadingVC: UIViewController?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var startTime = Date()

    private var maxWaitTime: TimeInterval {
        return kAPIRequestTimeout
    }

    private var rootVC: UIViewController? {
        UIViewController.topViewController()
    }

    private init() {
        $isLoading.removeDuplicates()
            .sink { [unowned self] isLoading in
                if isLoading {
                    guard loadingVC.isNil, ReachabilityManager.shared.hasConnectivity else { return }
                    startTimer()
                    self.loadingVC = self.rootVC?.present(style: .overFullScreen,
                                                          transitionStyle: .crossDissolve,
                                                          background: UIColor.black.withAlphaComponent(0.3),
                                                          builder: {
                                                              LoadingView()
                                                          })
                } else {
                    self.loadingVC?.dismiss(animated: false, completion: { [weak self] in
                        self?.loadingVC = nil
                    })
                }
            }
            .store(in: &cancellables)
    }

    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            let second = abs(self.startTime.timeIntervalSinceNow)
            if second >= self.maxWaitTime {
                self.loadingVC?.presentingViewController?.dismiss(animated: false, completion: nil)
                self.endTimer()
            }
        })
    }

    private func endTimer() {
        timer?.invalidate()
        timer = nil
    }
}
