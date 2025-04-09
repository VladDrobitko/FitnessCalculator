//
//  BMIScaleView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI

struct BMIScaleView: View {
    let bmi: Double
    
    // BMI категории и их цвета
    private let categories: [(range: ClosedRange<Double>, label: String, color: Color)] = [
        (0...16, "Severe Thinness", .red),
        (16.1...17, "Moderate Thinness", .orange),
        (17.1...18.5, "Mild Thinness", .yellow),
        (18.6...25, "Normal", .green),
        (25.1...30, "Overweight", .yellow),
        (30.1...35, "Obese Class I", .orange),
        (35.1...40, "Obese Class II", .red),
        (40.1...100, "Obese Class III", .purple)
    ]
    
    // Расположение отметки BMI на шкале (0-100%)
    private var indicatorPosition: CGFloat {
        let minBMI: CGFloat = 10
        let maxBMI: CGFloat = 45
        let range = maxBMI - minBMI
        
        let position = CGFloat((bmi - minBMI) / range)
        return max(0, min(1, position)) // ограничиваем от 0 до 1
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // BMI значение с категорией
            HStack {
                Text("Your BMI: ")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(String(format: "%.1f", bmi))")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Text("- \(currentCategory.label)")
                    .font(.headline)
                    .foregroundColor(currentCategory.color)
            }
            
            // Визуальная шкала BMI
            ZStack(alignment: .leading) {
                // Градиентная шкала
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .green, .yellow, .orange, .red, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 15)
                .cornerRadius(7.5)
                
                // Отметки категорий
                ForEach(0..<categories.count-1, id: \.self) { index in
                    GeometryReader { geometry in
                        let position = getCategoryPosition(for: categories[index].range.upperBound)
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: 25)
                            .position(x: position * geometry.size.width, y: 7.5)
                    }
                }
                
                // Индикатор текущего BMI
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Треугольная стрелка
                        Triangle()
                            .fill(Color.white)
                            .frame(width: 14, height: 7)
                        
                        // Круглый индикатор
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .fill(currentCategory.color)
                                    .frame(width: 14, height: 14)
                            )
                    }
                    .position(x: indicatorPosition * geometry.size.width, y: 0)
                }
            }
            .frame(height: 30)
            .padding(.top, 10)
            
            // Текстовые метки категорий BMI
            HStack {
                Text("Underweight")
                    .font(.caption)
                    .foregroundColor(.yellow)
                Spacer()
                Text("Normal")
                    .font(.caption)
                    .foregroundColor(.green)
                Spacer()
                Text("Overweight")
                    .font(.caption)
                    .foregroundColor(.orange)
                Spacer()
                Text("Obese")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 4)
            
            // Информация о BMI и рекомендации
            VStack(alignment: .leading, spacing: 8) {
                Text("What does your BMI mean?")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(bmiRecommendation)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
    
    // Получаем текущую категорию BMI
    private var currentCategory: (label: String, color: Color) {
        for category in categories {
            if category.range.contains(bmi) {
                return (category.label, category.color)
            }
        }
        return ("Unknown", .gray)
    }
    
    // Получаем относительную позицию для значения BMI
    private func getCategoryPosition(for value: Double) -> CGFloat {
        let minBMI: CGFloat = 10
        let maxBMI: CGFloat = 45
        let range = maxBMI - minBMI
        
        let position = CGFloat((value - minBMI) / range)
        return max(0, min(1, position))
    }
    
    // Рекомендации на основе BMI
    private var bmiRecommendation: String {
        switch bmi {
        case ..<18.5:
            return "Your BMI suggests you are underweight. Consider consulting with a healthcare provider about healthy ways to gain weight through balanced nutrition."
        case 18.5..<25:
            return "Your BMI is in the healthy range. Maintain your health with balanced nutrition and regular physical activity."
        case 25..<30:
            return "Your BMI indicates you are overweight. Consider focusing on healthier eating habits and increasing physical activity."
        default:
            return "Your BMI indicates obesity, which increases health risks. Consider consulting a healthcare provider for a personalized plan to achieve a healthier weight."
        }
    }
}

// Треугольная форма для индикатора
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct BMIScaleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                BMIScaleView(bmi: 18.2)
                    .padding()
                BMIScaleView(bmi: 23.5)
                    .padding()
                BMIScaleView(bmi: 27.8)
                    .padding()
                BMIScaleView(bmi: 32.4)
                    .padding()
            }
        }
    }
}


