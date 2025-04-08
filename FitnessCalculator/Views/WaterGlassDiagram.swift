//
//  WaterGlassDiagram.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI

struct WaterGlassDiagram: View {
    let dailyIntake: Double // в литрах
    let glassSize: Double = 250 // размер стакана в мл
    
    // Количество стаканов
    private var numberOfGlasses: Int {
        Int(dailyIntake * 1000 / glassSize)
    }
    
    // Процент заполнения для анимации
    @State private var fillPercentage: Double = 0
    
    var body: some View {
        VStack(spacing: 25) {
            // Заголовок
            Text("Recommended Water Intake")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 30) {
                // Кастомный стакан с водой
                ZStack(alignment: .bottom) {
                    // Пустой стакан
                    CustomGlass()
                        .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                        .frame(width: 100, height: 140)
                    
                    // Вода в стакане (градиент синего цвета)
                    CustomGlassWater(fillPercentage: fillPercentage)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 100, height: 140)
                }
                .padding(.bottom, 10)
                
                // Информация о потреблении
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(String(format: "%.1f", dailyIntake)) L")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("\(numberOfGlasses) glasses per day")
                        .font(.title3)
                        .foregroundColor(.blue)
                    
                    Text("(250 ml each)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 20)
            
            // Советы
            VStack(alignment: .leading, spacing: 10) {
                Text("Tips for staying hydrated:")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 5)
                
                VStack(alignment: .leading, spacing: 5) {
                    TipRow(text: "Start your day with a glass of water")
                    TipRow(text: "Keep a water bottle with you")
                    TipRow(text: "Set reminders throughout the day")
                    TipRow(text: "Drink a glass before each meal")
                }
                .padding(.leading, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .onAppear {
            // Анимация заполнения стакана при появлении
            withAnimation(.easeInOut(duration: 1.5)) {
                fillPercentage = 0.85 // заполняем стакан не до конца для лучшего визуального эффекта
            }
        }
    }
}

// Кастомная форма стакана
struct CustomGlass: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Параметры стакана
        let width = rect.width
        let height = rect.height
        let bottomWidth = width * 0.7
        let topWidth = width
        let bottomHeight = height * 0.1
        
        // Начинаем с нижнего левого угла
        path.move(to: CGPoint(x: (width - bottomWidth) / 2, y: height))
        
        // Нижняя часть стакана
        path.addLine(to: CGPoint(x: (width + bottomWidth) / 2, y: height))
        
        // Правая сторона стакана (слегка изогнутая для реалистичности)
        path.addCurve(
            to: CGPoint(x: width, y: bottomHeight),
            control1: CGPoint(x: (width + bottomWidth) / 2 + 10, y: height - bottomHeight),
            control2: CGPoint(x: width, y: height / 2)
        )
        
        // Верхняя часть стакана
        path.addLine(to: CGPoint(x: 0, y: bottomHeight))
        
        // Левая сторона стакана (слегка изогнутая для реалистичности)
        path.addCurve(
            to: CGPoint(x: (width - bottomWidth) / 2, y: height),
            control1: CGPoint(x: 0, y: height / 2),
            control2: CGPoint(x: (width - bottomWidth) / 2 - 10, y: height - bottomHeight)
        )
        
        return path
    }
}

// Кастомная форма воды в стакане
struct CustomGlassWater: Shape {
    var fillPercentage: Double
    
    var animatableData: Double {
        get { fillPercentage }
        set { fillPercentage = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Параметры стакана
        let width = rect.width
        let height = rect.height
        let bottomWidth = width * 0.68
        let waterHeight = height * (1 - fillPercentage)
        let waterTopWidth = width - (width - bottomWidth) * (waterHeight / height)
        
        // Начинаем с нижнего левого угла
        path.move(to: CGPoint(x: (width - bottomWidth) / 2, y: height))
        
        // Нижняя часть стакана
        path.addLine(to: CGPoint(x: (width + bottomWidth) / 2, y: height))
        
        // Правая сторона до уровня воды
        path.addCurve(
            to: CGPoint(x: (width + waterTopWidth) / 2, y: waterHeight),
            control1: CGPoint(x: (width + bottomWidth) / 2 + 10, y: height - height * 0.1),
            control2: CGPoint(x: (width + waterTopWidth) / 2 + 10, y: waterHeight + height * 0.1)
        )
        
        // Верхняя поверхность воды (с небольшой волной)
        path.addCurve(
            to: CGPoint(x: (width - waterTopWidth) / 2, y: waterHeight),
            control1: CGPoint(x: width / 2 + 15, y: waterHeight - 1),
            control2: CGPoint(x: width / 2 - 10, y: waterHeight - 9)
        )
        
        // Левая сторона до низа
        path.addCurve(
            to: CGPoint(x: (width - bottomWidth) / 2, y: height),
            control1: CGPoint(x: (width - waterTopWidth) / 2 - 10, y: waterHeight + height * 0.1),
            control2: CGPoint(x: (width - bottomWidth) / 2 - 10, y: height - height * 0.1)
        )
        
        return path
    }
}

// Компонент для строки совета
struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct WaterGlassDiagram_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            WaterGlassDiagram(dailyIntake: 2.5)
                .padding()
        }
    }
}
