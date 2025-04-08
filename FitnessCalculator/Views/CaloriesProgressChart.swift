//
//  CaloriesProgressChart.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI

struct CaloriesProgressChart: View {
    let tdee: Double
    let goalCalories: Double
    let goal: Goal
    let currentWeight: Double
    
    // Расчетные данные
    private var calorieDeficitSurplus: Double {
        goalCalories - tdee
    }
    
    private var weeklyWeightChange: Double {
        // 7700 kcal = примерно 1 кг жира
        calorieDeficitSurplus * 7 / 7700
    }
    
    private var monthlyWeightChange: Double {
        weeklyWeightChange * 4.3
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            Text("Weight Progress Projection")
                .font(.headline)
                .foregroundColor(.white)
            
            // Информация о калориях
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Maintenance")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text("\(Int(tdee)) kcal")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Стрелка вверх или вниз в зависимости от цели
                Image(systemName: goal == .lose ? "arrow.down" : (goal == .gain ? "arrow.up" : "arrow.left.and.right"))
                    .foregroundColor(goal == .maintain ? .yellow : (goal == .lose ? .red : .green))
                    .font(.system(size: 24))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Goal")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text("\(Int(goalCalories)) kcal")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(goal == .maintain ? .yellow : (goal == .lose ? .red : .green))
                }
            }
            .padding(.vertical, 10)
            
            // Разделитель
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Ежедневная разница в калориях
            VStack(spacing: 5) {
                Text("Daily Calorie \(goal == .lose ? "Deficit" : (goal == .gain ? "Surplus" : "Balance"))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text("\(abs(Int(calorieDeficitSurplus))) kcal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(goal == .maintain ? .yellow : (goal == .lose ? .red : .green))
            }
            .padding(.vertical, 5)
            
            // График прогнозируемого изменения веса
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок прогноза
                Text("Estimated Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if goal != .maintain {
                    // Прогресс по неделям
                    WeeklyProgressView(
                        startWeight: currentWeight,
                        weeklyChange: weeklyWeightChange,
                        goal: goal
                    )
                } else {
                    Text("Your calorie intake is set to maintain your current weight.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            
            // Важное примечание
            VStack(alignment: .leading, spacing: 5) {
                Text("Note:")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text("This is a theoretical projection based on calorie estimates. Actual results may vary based on metabolism, activity level, and consistency.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

// Компонент для отображения недельного прогресса
struct WeeklyProgressView: View {
    let startWeight: Double
    let weeklyChange: Double
    let goal: Goal
    
    var body: some View {
        VStack(spacing: 15) {
            // Заголовки
            HStack {
                Text("Timeline")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .leading)
                
                Text("Projected Weight")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Change")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 70, alignment: .trailing)
            }
            
            // Прогноз по неделям
            ForEach(0..<5) { week in
                HStack {
                    // Временная метка
                    Text("Week \(week + 1)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 80, alignment: .leading)
                    
                    // Полоса прогресса
                    ZStack(alignment: .leading) {
                        // Фон
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 24)
                        
                        // Линия прогресса
                        Rectangle()
                            .fill(goal == .lose ? Color.red : Color.green)
                            .frame(width: getProgressWidth(forWeek: Double(week + 1)), height: 24)
                        
                        // Текущий прогнозируемый вес
                        Text("\(String(format: "%.1f", getWeightForWeek(Double(week + 1)))) kg")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                    }
                    .cornerRadius(5)
                    
                    // Изменение веса
                    let change = weeklyChange * Double(week + 1)
                    Text("\(change > 0 ? "+" : "")\(String(format: "%.1f", change)) kg")
                        .font(.system(size: 14))
                        .foregroundColor(goal == .lose ? .red : .green)
                        .frame(width: 70, alignment: .trailing)
                }
            }
            
            // Месячный прогноз
            HStack {
                Text("After 1 month")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 80, alignment: .leading)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 30)
                    
                    Rectangle()
                        .fill(goal == .lose ? Color.red : Color.green)
                        .frame(width: getProgressWidth(forWeek: 4.3), height: 30)
                    
                    Text("\(String(format: "%.1f", getWeightForWeek(4.3))) kg")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                }
                .cornerRadius(5)
                
                let monthlyChange = weeklyChange * 4.3
                Text("\(monthlyChange > 0 ? "+" : "")\(String(format: "%.1f", monthlyChange)) kg")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(goal == .lose ? .red : .green)
                    .frame(width: 70, alignment: .trailing)
            }
        }
    }
    
    // Получаем прогнозируемый вес для заданной недели
    private func getWeightForWeek(_ week: Double) -> Double {
        return startWeight + (weeklyChange * week)
    }
    
    // Получаем ширину полосы прогресса для визуализации
    private func getProgressWidth(forWeek week: Double) -> CGFloat {
        // Предполагаем, что максимальная ширина полосы прогресса - 200
        let maxWidth: CGFloat = 200
        
        // Для похудения: startWeight это 100%, целевой вес - меньше
        // Для набора: startWeight это 0%, целевой вес - больше
        
        if goal == .lose {
            // Для похудения максимальное возможное снижение 10% от стартового веса
            let minPossibleWeight = startWeight * 0.9
            let currentWeight = getWeightForWeek(week)
            let progressPercentage = 1.0 - ((currentWeight - minPossibleWeight) / (startWeight - minPossibleWeight))
            return min(maxWidth * CGFloat(progressPercentage), maxWidth)
        } else {
            // Для набора максимальное возможное увеличение 10% от стартового веса
            let maxPossibleWeight = startWeight * 1.1
            let currentWeight = getWeightForWeek(week)
            let progressPercentage = (currentWeight - startWeight) / (maxPossibleWeight - startWeight)
            return min(maxWidth * CGFloat(progressPercentage), maxWidth)
        }
    }
}

struct CaloriesProgressChart_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    CaloriesProgressChart(
                        tdee: 2500,
                        goalCalories: 2000,
                        goal: .lose,
                        currentWeight: 80
                    )
                    
                    CaloriesProgressChart(
                        tdee: 2500,
                        goalCalories: 2800,
                        goal: .gain,
                        currentWeight: 70
                    )
                    
                    CaloriesProgressChart(
                        tdee: 2500,
                        goalCalories: 2500,
                        goal: .maintain,
                        currentWeight: 75
                    )
                }
                .padding()
            }
        }
    }
}
