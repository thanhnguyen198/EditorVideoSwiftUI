//
//  View.swift
//  SwiftUITemplate
//
//  Created by apple on 17/04/2023.
//

import SwiftUI
extension View {
    func navigationBar<Leading, Middle, Trailing>(@ViewBuilder leading: @escaping () -> Leading,
                                                  @ViewBuilder middle: @escaping () -> Middle,
                                                  @ViewBuilder trailing: @escaping () -> Trailing) -> some View where Leading: View, Middle: View, Trailing: View {
        return modifier(ViewWithNavigationBar(leading: leading, middle: middle, trailing: trailing))
    }

    func navigationBar<Leading, Middle, Trailing>(@ViewBuilder leading: @escaping () -> Leading,
                                                  @ViewBuilder middle: @escaping () -> Middle,
                                                  @ViewBuilder trailing: @escaping () -> Trailing,
                                                  backgroundColor: Color = .clear) -> some View where Leading: View, Middle: View, Trailing: View {
        return modifier(ViewWithNavigationBar(leading: leading, middle: middle, trailing: trailing, backgroundColor: backgroundColor))
    }

    func navigationBar(title: String) -> some View {
        navigationBar(leading: { EmptyView() },
                      middle: {
                          Text(title)
                              .bold()
                              .font(.title2)
                      },
                      trailing: { EmptyView() })
    }

    func size(_ size: CGFloat) -> some View {
        frame(width: size, height: size)
    }

    func navigationBar(title: String,
                       backButtonTitle: String,
                       presentationMode: Binding<PresentationMode>,
                       @ViewBuilder trailing: @escaping () -> some View,
                       backgroundColor: Color = .clear) -> some View {
        navigationBar(leading: {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text(backButtonTitle)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }, middle: {
            Text(title)
                .foregroundColor(.black)
                .bold()
                .font(.title2)
        }, trailing: {
            trailing()
        }, backgroundColor: backgroundColor)
    }

    func navigationBar(backButtonTitle: String,
                       presentationMode: Binding<PresentationMode>,
                       @ViewBuilder middle: @escaping () -> some View,
                       @ViewBuilder trailing: @escaping () -> some View) -> some View {
        navigationBar {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text(backButtonTitle)
                }
            }
            .buttonStyle(PlainButtonStyle())
        } middle: {
            middle()
        } trailing: {
            trailing()
        }
    }

    func navigation<Item>(
        item: Binding<Item?>,
        isAdditionalSwipeBack: Bool = true,
        @ViewBuilder destination: (Item) -> some View
    ) -> some View {
        let isActive = Binding(
            get: { item.wrappedValue != nil },
            set: { value in
                if !value {
                    item.wrappedValue = nil
                }
            }
        )
        return navigation(isActive: isActive, isAdditionalSwipeBack: isAdditionalSwipeBack) {
            item.wrappedValue.map(destination)
        }
    }

    func navigation(
        isActive: Binding<Bool>,
        isAdditionalSwipeBack: Bool = true,
        @ViewBuilder destination: () -> some View
    ) -> some View {
        return overlay(
            NavigationLink(
                destination: isActive.wrappedValue ? destination().addSwipeBack(canDismiss: isAdditionalSwipeBack) : nil,
                isActive: isActive,
                label: { EmptyView() }
            )
        )
    }

    func onSwipeBackGesture(swipeRight: @escaping () -> Void = {}) -> some View {
        return simultaneousGesture(
            DragGesture()
                .onEnded({ value in
                    if value.translation.width > 0 && abs(value.translation.height) < 30 && value.startLocation.x < CGFloat(50) {
                        swipeRight()
                    }
                })
        )
    }

    func addSwipeBack(canDismiss: Bool = true, action: @escaping () -> Void = {}) -> some View {
        return DestinationView(content: {
            self
        }, action: {
            action()
        }, canDismiss: canDismiss)
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
//    public func focused<T>(file: StaticString = #file, _ state: FocusState<T>, equals value: T) -> some View {
//        modifier(FocusedModifier(state: state, id: value, file: file))
//    }
}

struct DestinationView<T: View>: View {
    @Environment(\.presentationMode) var presentationMode
    var content: () -> T
    var action: () -> Void
    var canDismiss: Bool
    var body: some View {
        content().onSwipeBackGesture {
            action()
            if canDismiss {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
