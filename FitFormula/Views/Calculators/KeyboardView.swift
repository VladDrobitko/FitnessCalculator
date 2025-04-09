//
//  KeyboardView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//
import SwiftUI

struct KeyboardDoneButtonModifier: ViewModifier {
    @State private var keyboardIsShown = false
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack(spacing: 0) {
                    Spacer()
                    if isAnimating {
                        HStack(spacing: 0) {
                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                              to: nil, from: nil, for: nil)
                            }) {
                                Text("Done")
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .background(Color(UIColor.systemGray5))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .bottom))
                    }
                }
            )
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    // Получаем параметры анимации клавиатуры
                    let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
                    let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
                    
                    // Установим переменную keyboardIsShown немедленно
                    keyboardIsShown = true
                    
                    // Преобразуем системную кривую анимации в анимацию SwiftUI
                    let animation: Animation
                    if curveValue == UIView.AnimationCurve.easeIn.rawValue {
                        animation = .easeIn(duration: duration)
                    } else if curveValue == UIView.AnimationCurve.easeOut.rawValue {
                        animation = .easeOut(duration: duration)
                    } else if curveValue == UIView.AnimationCurve.linear.rawValue {
                        animation = .linear(duration: duration)
                    } else {
                        // UIView.AnimationCurve.easeInOut.rawValue и другие случаи
                        animation = .easeInOut(duration: duration)
                    }
                    
                    // Добавим очень небольшую задержку для лучшей синхронизации
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        withAnimation(animation) {
                            isAnimating = true
                        }
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
                    // Получаем параметры анимации клавиатуры
                    let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
                    let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
                    
                    // Преобразуем системную кривую анимации в анимацию SwiftUI
                    let animation: Animation
                    if curveValue == UIView.AnimationCurve.easeIn.rawValue {
                        animation = .easeIn(duration: duration)
                    } else if curveValue == UIView.AnimationCurve.easeOut.rawValue {
                        animation = .easeOut(duration: duration)
                    } else if curveValue == UIView.AnimationCurve.linear.rawValue {
                        animation = .linear(duration: duration)
                    } else {
                        // UIView.AnimationCurve.easeInOut.rawValue и другие случаи
                        animation = .easeInOut(duration: duration)
                    }
                    
                    withAnimation(animation) {
                        isAnimating = false
                    }
                    
                    // Сбросим флаг после завершения анимации
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        keyboardIsShown = false
                    }
                }
            }
            .onDisappear {
                // Убираем наблюдателей при исчезновении View
                NotificationCenter.default.removeObserver(self)
            }
    }
}

// Расширение для использования модификатора
extension View {
    func addKeyboardDoneButton() -> some View {
        self.modifier(KeyboardDoneButtonModifier())
    }
}



extension View {
    func keyboardDoneButton() -> some View {
        self.modifier(KeyboardDoneButtonModifier())
    }
}
