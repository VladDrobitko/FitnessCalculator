//
//  CaloriesStatisticsView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI
import Charts

struct CaloriesStatisticsView: View {
    let history: [CalculationHistory]
    let timeRange: TimeRange
    
    // Структура данных для графика
    struct CalorieDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let tdee: Double
        let goal: Double
        let goalType: String // "maintain", "lose", "gain"
        
        var deficit: Double {
            tdee - goal
        }
        
        var color: Color {
            switch goalType {
            case "maintain":
                return .blue
            case "lose":
                return .green
            case "gain":
                return .orange
            default:
                return .gray
            }
        }
    }
    
    // Преобразование истории в данные для графика
    private var dataPoints: [CalorieDataPoint] {
        // Сортируем по дате и преобразуем данные
        let sortedEntries = history.sorted { $0.date < $1.date }
        
        return sortedEntries.compactMap { entry -> CalorieDataPoint? in
            // Пытаемся извлечь структурированные данные
            if let calorieData = entry.calories {
                return CalorieDataPoint(
                    date: entry.date,
                    tdee: calorieData.tdee,
                    goal: calorieData.goalCalories,
                    goalType: calorieData.goal
                )
            } else {
                // Резервный вариант - извлекаем из строки
                let dict = parseResult(entry.result)
                if let tdeeStr = dict["tdee"],
                   let goalCaloriesStr = dict["goalCalories"],
                   let goalStr = dict["goal"],
                   let tdee = Double(tdeeStr),
                   let goalCalories = Double(goalCaloriesStr) {
                    return CalorieDataPoint(
                        date: entry.date,
                        tdee: tdee,
                        goal: goalCalories,
                        goalType: goalStr
                    )
                }
            }
            return nil
        }
    }
    
    var body: some View {
        if dataPoints.isEmpty {
            EmptyStatisticsView(type: "Calories")
        } else {
            VStack(spacing: 24) {
                // Основная статистика
                CaloriesStatsCard(dataPoints: dataPoints)
                
                // График калорий
                CaloriesChartView(dataPoints: dataPoints)
                
                // Информация о дефиците/профиците
                CaloriesBalanceView(dataPoints: dataPoints)
            }
        }
    }
    
    // Парсинг результата
    private func parseResult(_ result: String) -> [String: String] {
        var dict: [String: String] = [:]
        let components = result.split(separator: ";")
        for pair in components {
            let keyValue = pair.split(separator: "=")
            if keyValue.count == 2 {
                let key = String(keyValue[0])
                let value = String(keyValue[1])
                dict[key] = value
            }
        }
        return dict
    }
}

// Карточка с основной статистикой калорий
struct CaloriesStatsCard: View {
    let dataPoints: [CaloriesStatisticsView.CalorieDataPoint]
    
    private var latestTDEE: Double {
        dataPoints.last?.tdee ?? 0
    }
    
    private var latestGoal: Double {
        dataPoints.last?.goal ?? 0
    }
    
    private var latestGoalType: String {
        dataPoints.last?.goalType ?? "maintain"
    }
    
    private var averageTDEE: Double {
        let sum = dataPoints.reduce(0) { $0 + $1.tdee }
        return dataPoints.isEmpty ? 0 : sum / Double(dataPoints.count)
    }
    
    private var averageGoal: Double {
        let sum = dataPoints.reduce(0) { $0 + $1.goal }
        return dataPoints.isEmpty ? 0 : sum / Double(dataPoints.count)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Calories Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            // Текущие показатели
            HStack(spacing: 20) {
                StatCard(title: "Current TDEE", value: "\(Int(latestTDEE)) kcal", color: .white)
                StatCard(title: "Goal", value: "\(Int(latestGoal)) kcal",
                         color: goalColor(for: latestGoalType))
                StatCard(title: "Type", value: goalDescription(for: latestGoalType),
                         color: goalColor(for: latestGoalType))
            }
            
            // Средние показатели
            HStack(spacing: 20) {
                StatCard(title: "Avg TDEE", value: "\(Int(averageTDEE)) kcal", color: .gray)
                StatCard(title: "Avg Goal", value: "\(Int(averageGoal)) kcal", color: .gray)
                StatCard(title: "Entries", value: "\(dataPoints.count)", color: .gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func goalColor(for goalType: String) -> Color {
        switch goalType {
        case "maintain":
            return .blue
        case "lose":
            return .green
        case "gain":
            return .orange
        default:
            return .gray
        }
    }
    
    private func goalDescription(for goalType: String) -> String {
        switch goalType {
        case "maintain":
            return "Maintain"
        case "lose":
            return "Weight Loss"
        case "gain":
            return "Weight Gain"
        default:
            return goalType.capitalized
        }
    }
}

// График калорий
struct CaloriesChartView: View {
    let dataPoints: [CaloriesStatisticsView.CalorieDataPoint]
    
    @State private var showTDEE = true
    @State private var showGoal = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Calories Timeline")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 10)
            
            VStack(spacing: 16) {
                // График
                Chart {
                    if showTDEE {
                        ForEach(dataPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("TDEE", point.tdee)
                            )
                            .foregroundStyle(.white)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("TDEE", point.tdee)
                            )
                            .foregroundStyle(.white)
                            .symbolSize(40)
                        }
                    }
                    
                    if showGoal {
                        ForEach(dataPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Goal", point.goal)
                            )
                            .foregroundStyle(point.color)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Goal", point.goal)
                            )
                            .foregroundStyle(point.color)
                            .symbolSize(40)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .frame(height: 260)
                
                // Переключатели отображения данных
                HStack {
                    Toggle("TDEE", isOn: $showTDEE)
                        .toggleStyle(ButtonToggleStyle(showTDEE ? .white : .gray))
                    
                    Toggle("Goal", isOn: $showGoal)
                        .toggleStyle(ButtonToggleStyle(.green))
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(10)
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

// Стиль кнопки-переключателя
struct ButtonToggleStyle: ToggleStyle {
    let color: Color
    
    init(_ color: Color) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                configuration.label
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .foregroundColor(configuration.isOn ? color : .gray)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
        }
    }
}

// Информация о балансе калорий
struct CaloriesBalanceView: View {
    let dataPoints: [CaloriesStatisticsView.CalorieDataPoint]
    
    private var averageDeficit: Double {
        let sum = dataPoints.reduce(0) { $0 + $1.deficit }
        return dataPoints.isEmpty ? 0 : sum / Double(dataPoints.count)
    }
    
    private var totalWeightImpact: Double {
        // Приблизительно 7700 ккал = 1 кг жира
        let totalDeficit = dataPoints.reduce(0) { $0 + $1.deficit }
        return totalDeficit / 7700
    }
    
    private var weeklyWeightImpact: Double {
        // Средний дневной дефицит/профицит * 7 дней / 7700 = еженедельное изменение веса в кг
        return (averageDeficit * 7) / 7700
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Calorie Balance Impact")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // Средний дефицит/профицит
                VStack(spacing: 5) {
                    Text("Average Daily")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    let deficitText = averageDeficit > 0 ?
                        "Surplus: +\(Int(abs(averageDeficit))) kcal" :
                        "Deficit: -\(Int(abs(averageDeficit))) kcal"
                    
                    Text(deficitText)
                        .font(.subheadline)
                        .foregroundColor(averageDeficit > 0 ? .orange : .green)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Color.white.opacity(0.03))
                .cornerRadius(10)
                
                // Еженедельное влияние на вес
                VStack(spacing: 5) {
                    Text("Weekly Impact")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    let weeklyText = weeklyWeightImpact > 0 ?
                        "+\(String(format: "%.2f", abs(weeklyWeightImpact))) kg/week" :
                        "-\(String(format: "%.2f", abs(weeklyWeightImpact))) kg/week"
                    
                    Text(weeklyText)
                        .font(.subheadline)
                        .foregroundColor(weeklyWeightImpact > 0 ? .orange : .green)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Color.white.opacity(0.03))
                .cornerRadius(10)
            }
            
            // Прогресс-бар с прогнозом на месяц
            VStack(alignment: .leading, spacing: 8) {
                Text("Potential 30-Day Weight Change")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Прогресс-бар
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Фон
                        Rectangle()
                            .frame(width: geometry.size.width, height: 24)
                            .foregroundColor(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        
                        // Шкала с центральной отметкой
                        Rectangle()
                            .frame(width: 2, height: 32)
                            .foregroundColor(.gray)
                            .position(x: geometry.size.width / 2, y: 12)
                        
                        // Индикатор
                        let monthlyChange = weeklyWeightImpact * 4.3 // ~месяц
                        let maxChange = 5.0 // максимальное изменение +/- 5 кг
                        let position = (monthlyChange / (maxChange * 2)) + 0.5 // нормализуем от 0 до 1
                        let cappedPosition = max(0, min(1, position))
                        
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(monthlyChange > 0 ? .orange : .green)
                            .position(x: cappedPosition * geometry.size.width, y: 12)
                        
                        Text(String(format: "%.1f", monthlyChange))
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .position(x: cappedPosition * geometry.size.width, y: 12)
                    }
                }
                .frame(height: 24)
                
                // Шкала
                HStack {
                    Text("-5 kg")
                        .font(.caption)
                        .foregroundColor(.green)
                    Spacer()
                    Text("No change")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("+5 kg")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}


