//
//  KeyboardView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

