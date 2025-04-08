//
//  MacrosPieChart.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI

struct MacrosPieChart: View {
    let protein: Double
    let fat: Double
    let carbs: Double
    
    // Цвета для макросов
    private let proteinColor = Color.green
    private let fatColor = Color.yellow
    private let carbsColor = Color.blue
    
    // Рассчитываем общее количество калорий
    private var totalCalories: Double {
        (protein * 4) + (fat * 9) + (carbs * 4)
    }
    
    // Рассчитываем проценты для каждого макроса
    private var proteinPercentage: Double {
        (protein * 4) / totalCalories
    }
    
    private var fatPercentage: Double {
        (fat * 9) / totalCalories
    }
    
    private var carbsPercentage: Double {
        (carbs * 4) / totalCalories
    }

    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            Text("Macronutrient Distribution")
                .font(.headline)
                .foregroundColor(.white)
            
            // Круговая диаграмма
            ZStack {
                CircleChart(
                    segments: [
                        Segment(value: proteinPercentage, color: proteinColor),
                        Segment(value: fatPercentage, color: fatColor),
                        Segment(value: carbsPercentage, color: carbsColor)
                    ]
                )
                .frame(width: 180, height: 180)
                
                // Круг в центре для лучшего вида
                Circle()
                    .fill(Color.black)
                    .frame(width: 60, height: 60)
                
                // Общие калории в центре
                VStack {
                    Text("\(Int(totalCalories))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("kcal")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            // Легенда
            VStack(spacing: 15) {
                MacroLegendItem(
                    color: proteinColor,
                    title: "Protein",
                    amount: protein,
                    percentage: proteinPercentage,
                    calories: protein * 4
                )
                
                MacroLegendItem(
                    color: fatColor,
                    title: "Fat",
                    amount: fat,
                    percentage: fatPercentage,
                    calories: fat * 9
                )
                
                MacroLegendItem(
                    color: carbsColor,
                    title: "Carbs",
                    amount: carbs,
                    percentage: carbsPercentage,
                    calories: carbs * 4
                )
            }
            .padding(.top, 10)
            
            // Примеры продуктов для каждого макроса
            MacroExamples()
                .padding(.top, 20)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

// Структура для сегмента диаграммы
struct Segment {
    let value: Double
    let color: Color
}

// Компонент круговой диаграммы
struct CircleChart: View {
    let segments: [Segment]
    
    var body: some View {
        Canvas { context, size in
            // Центр круга
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            // Начальный угол (в радианах)
            var startAngle = -Double.pi / 2
            
            // Рисуем каждый сегмент
            for segment in segments {
                // Вычисляем конечный угол
                let endAngle = startAngle + 2 * Double.pi * segment.value
                
                // Создаем путь для сегмента
                var path = Path()
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: Angle(radians: startAngle),
                    endAngle: Angle(radians: endAngle),
                    clockwise: false
                )
                path.closeSubpath()
                
                // Заполняем сегмент цветом
                context.fill(path, with: .color(segment.color))
                
                // Обновляем начальный угол для следующего сегмента
                startAngle = endAngle
            }
        }
    }
}

// Элемент легенды для макросов
struct MacroLegendItem: View {
    let color: Color
    let title: String
    let amount: Double
    let percentage: Double
    let calories: Double
    
    var body: some View {
        HStack {
            // Цветной индикатор
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            // Название макроса
            Text(title)
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            
            // Количество в граммах
            Text("\(Int(amount))g")
                .foregroundColor(.white)
                .frame(width: 50)
            
            // Процент от общего количества калорий
            Text("\(Int(percentage * 100))%")
                .foregroundColor(.gray)
            
            Spacer()
            
            // Калории из этого макроса
            Text("\(Int(calories)) kcal")
                .foregroundColor(.white)
                .frame(width: 80, alignment: .trailing)
        }
        .font(.system(size: 14))
    }
}

// Примеры продуктов для каждого макроса
struct MacroExamples: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Food Sources")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            Group {
                Text("• Protein: chicken, fish, tofu, beans, eggs")
                Text("• Fat: avocado, nuts, olive oil, fatty fish")
                Text("• Carbs: rice, potatoes, fruits, whole grains")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
    }
}

struct MacrosPieChart_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            MacrosPieChart(protein: 150, fat: 60, carbs: 200)
                .padding()
        }
    }
}
