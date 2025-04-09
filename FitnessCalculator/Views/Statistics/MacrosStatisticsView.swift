//
//  MacrosStatisticsView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI
import Charts

// MARK: - Статистика по макроэлементам

struct MacrosStatisticsView: View {
    let history: [CalculationHistory]
    let timeRange: TimeRange
    
    // Структура данных для макроэлементов
    struct MacroDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let protein: Double
        let fat: Double
        let carbs: Double
        
        var totalCalories: Double {
            (protein * 4) + (fat * 9) + (carbs * 4)
        }
        
        var proteinPercentage: Double {
            (protein * 4) / totalCalories
        }
        
        var fatPercentage: Double {
            (fat * 9) / totalCalories
        }
        
        var carbsPercentage: Double {
            (carbs * 4) / totalCalories
        }
    }
    
    // Преобразование истории в данные для графика
    private var dataPoints: [MacroDataPoint] {
        // Сортируем по дате и преобразуем данные
        let sortedEntries = history.sorted { $0.date < $1.date }
        
        return sortedEntries.compactMap { entry -> MacroDataPoint? in
            // Пытаемся извлечь структурированные данные
            if let macrosData = entry.macros {
                return MacroDataPoint(
                    date: entry.date,
                    protein: macrosData.protein,
                    fat: macrosData.fat,
                    carbs: macrosData.carbs
                )
            } else {
                // Резервный вариант - извлекаем из строки
                let dict = parseResult(entry.result)
                if let proteinStr = dict["protein"],
                   let fatStr = dict["fat"],
                   let carbsStr = dict["carbs"],
                   let protein = Double(proteinStr),
                   let fat = Double(fatStr),
                   let carbs = Double(carbsStr) {
                    return MacroDataPoint(
                        date: entry.date,
                        protein: protein,
                        fat: fat,
                        carbs: carbs
                    )
                }
            }
            return nil
        }
    }
    
    var body: some View {
        if dataPoints.isEmpty {
            EmptyStatisticsView(type: "Macros")
        } else {
            GeometryReader { geometry in
                let availableWidth = geometry.size.width
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Основная статистика
                        MacrosStatsCard(dataPoints: dataPoints)
                            .frame(width: min(availableWidth - 32, 600))
                        
                        // График динамики макроэлементов
                        MacrosChartView(dataPoints: dataPoints)
                            .frame(width: min(availableWidth - 32, 600))
                        
                        // Соотношение макроэлементов в последнем расчете
                        MacrosDistributionView(dataPoint: dataPoints.last!)
                            .frame(width: min(availableWidth - 32, 600))
                    }
                    .padding(.vertical)
                }
                .frame(width: availableWidth)
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

// Карточка с основной статистикой макроэлементов
struct MacrosStatsCard: View {
    let dataPoints: [MacrosStatisticsView.MacroDataPoint]
    
    private var averageProtein: Double {
        let sum = dataPoints.reduce(0) { $0 + $1.protein }
        return dataPoints.isEmpty ? 0 : sum / Double(dataPoints.count)
    }
    
    private var averageFat: Double {
        let sum = dataPoints.reduce(0) { $0 + $1.fat }
        return dataPoints.isEmpty ? 0 : sum / Double(dataPoints.count)
    }
    
    private var averageCarbs: Double {
        let sum = dataPoints.reduce(0) { $0 + $1.carbs }
        return dataPoints.isEmpty ? 0 : sum / Double(dataPoints.count)
    }
    
    private var latestValues: MacrosStatisticsView.MacroDataPoint? {
        return dataPoints.last
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Macros Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            // Текущие показатели
            if let latest = latestValues {
                HStack(spacing: 20) {
                    StatCard(title: "Protein", value: "\(Int(latest.protein))g", color: .green)
                    StatCard(title: "Fat", value: "\(Int(latest.fat))g", color: .yellow)
                    StatCard(title: "Carbs", value: "\(Int(latest.carbs))g", color: .blue)
                }
                
                // Процентное соотношение
                HStack(spacing: 20) {
                    StatCard(
                        title: "Protein %",
                        value: "\(Int(latest.proteinPercentage * 100))%",
                        color: .green
                    )
                    StatCard(
                        title: "Fat %",
                        value: "\(Int(latest.fatPercentage * 100))%",
                        color: .yellow
                    )
                    StatCard(
                        title: "Carbs %",
                        value: "\(Int(latest.carbsPercentage * 100))%",
                        color: .blue
                    )
                }
            }
            
            // Средние показатели
            HStack(spacing: 20) {
                StatCard(title: "Avg Protein", value: "\(Int(averageProtein))g", color: .gray)
                StatCard(title: "Avg Fat", value: "\(Int(averageFat))g", color: .gray)
                StatCard(title: "Entries", value: "\(dataPoints.count)", color: .gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// График динамики макроэлементов
struct MacrosChartView: View {
    let dataPoints: [MacrosStatisticsView.MacroDataPoint]
    
    @State private var showProtein = true
    @State private var showFat = true
    @State private var showCarbs = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Macros Timeline")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 10)
            
            VStack(spacing: 16) {
                // График
                Chart {
                    if showProtein {
                        ForEach(dataPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Protein", point.protein)
                            )
                            .foregroundStyle(.green)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                    }
                    
                    if showFat {
                        ForEach(dataPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Fat", point.fat)
                            )
                            .foregroundStyle(.yellow)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                    }
                    
                    if showCarbs {
                        ForEach(dataPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Carbs", point.carbs)
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 2))
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
                    Toggle("Protein", isOn: $showProtein)
                        .toggleStyle(ButtonToggleStyle(.green))
                    
                    Toggle("Fat", isOn: $showFat)
                        .toggleStyle(ButtonToggleStyle(.yellow))
                    
                    Toggle("Carbs", isOn: $showCarbs)
                        .toggleStyle(ButtonToggleStyle(.blue))
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Визуализация соотношения макроэлементов
struct MacrosDistributionView: View {
    let dataPoint: MacrosStatisticsView.MacroDataPoint
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Macros Distribution")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                // Круговая диаграмма
                ZStack {
                    Circle()
                        .trim(from: 0, to: CGFloat(dataPoint.proteinPercentage))
                        .stroke(Color.green, lineWidth: 20)
                        .rotationEffect(.degrees(-90))
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(dataPoint.fatPercentage))
                        .stroke(Color.yellow, lineWidth: 20)
                        .rotationEffect(.degrees(-90 + 360 * dataPoint.proteinPercentage))
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(dataPoint.carbsPercentage))
                        .stroke(Color.blue, lineWidth: 20)
                        .rotationEffect(.degrees(-90 + 360 * (dataPoint.proteinPercentage + dataPoint.fatPercentage)))
                    
                    // Отображение общих калорий в центре
                    VStack {
                        Text("\(Int(dataPoint.totalCalories))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("kcal")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 180)
                .padding(.vertical)
                
                // Легенда
                VStack(spacing: 15) {
                    MacroLegendRow(
                        color: .green,
                        macroName: "Protein",
                        amount: dataPoint.protein,
                        percentage: dataPoint.proteinPercentage,
                        calories: dataPoint.protein * 4
                    )
                    
                    MacroLegendRow(
                        color: .yellow,
                        macroName: "Fat",
                        amount: dataPoint.fat,
                        percentage: dataPoint.fatPercentage,
                        calories: dataPoint.fat * 9
                    )
                    
                    MacroLegendRow(
                        color: .blue,
                        macroName: "Carbs",
                        amount: dataPoint.carbs,
                        percentage: dataPoint.carbsPercentage,
                        calories: dataPoint.carbs * 4
                    )
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Используем новую структуру для легенды макронутриентов, чтобы избежать конфликтов
struct MacroLegendRow: View {
    let color: Color
    let macroName: String
    let amount: Double
    let percentage: Double
    let calories: Double
    
    var body: some View {
        HStack(spacing: 10) {
            // Цветной индикатор
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            // Информация о макронутриенте
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(macroName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(percentage * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("\(Int(amount))g")
                        .font(.caption)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Text("\(Int(calories)) kcal")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// Превью для отладки
struct MacrosStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Создаем тестовые данные для превью
            MacrosStatisticsView(
                history: [
                    createSampleMacrosHistory(protein: 150, fat: 70, carbs: 250, daysAgo: 7),
                    createSampleMacrosHistory(protein: 145, fat: 65, carbs: 230, daysAgo: 5),
                    createSampleMacrosHistory(protein: 160, fat: 75, carbs: 240, daysAgo: 3),
                    createSampleMacrosHistory(protein: 155, fat: 68, carbs: 245, daysAgo: 0)
                ],
                timeRange: .month
            )
        }
        .preferredColorScheme(.dark)
        // Ограничиваем размер для превью, чтобы видеть проблемы с размерами
        .previewLayout(.fixed(width: 375, height: 800))
    }
    
    // Вспомогательная функция для создания тестовых данных
    static func createSampleMacrosHistory(protein: Double, fat: Double, carbs: Double, daysAgo: Int) -> CalculationHistory {
        let entry = CalculationHistory(
            title: "Macros",
            result: "protein=\(protein);fat=\(fat);carbs=\(carbs)"
        )
        
        // Устанавливаем дату в прошлом
        if daysAgo > 0 {
            entry.date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        }
        
        // Устанавливаем структурированные данные
        entry.macros = MacrosData(protein: protein, fat: fat, carbs: carbs)
        
        return entry
    }
}






