//
//  DragIndicator.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 07/04/2025.
//

import SwiftUI

struct DragIndicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .frame(width: 40, height: 5)
            .foregroundColor(Color.gray.opacity(0.5))
            .padding(.top, 8)
            .padding(.bottom, 8)
    }
}

// Модификатор для добавления индикатора перетаскивания к любому представлению
struct WithDragIndicator: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            DragIndicator()
            content
        }
    }
}

extension View {
    func withDragIndicator() -> some View {
        modifier(WithDragIndicator())
    }
}

#Preview {
    DragIndicator()
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.black)
}
