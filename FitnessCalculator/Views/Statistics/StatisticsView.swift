//
//  StatisticsView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var history: [CalculationHistory]
    
    // Состояния для фильтров и настроек
    @State private var selectedCalculatorType: CalculatorType = .bmi
    @State private var selectedTimeRange: TimeRange = .month
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Фильтры вверху
                    VStack(spacing: 12) {
                        // Пикер калькулятора
                        Picker("Calculator", selection: $selectedCalculatorType) {
                            ForEach([CalculatorType.bmi, .calories, .macros, .water], id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .tint(.green)
                        
                        // Пикер временного периода
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    .padding(.bottom, 8)
                    .background(Color.black)
                    .zIndex(1) // Чтобы фильтры всегда были поверх содержимого
                    
                    // Содержимое в зависимости от выбранного калькулятора
                    // Используем GeometryReader для получения размеров экрана
                    GeometryReader { geometry in
                        let availableWidth = geometry.size.width
                        
                        // Вложенный ScrollView
                        ScrollView {
                            // Добавляем отступ сверху, чтобы не перекрывать фильтры
                            VStack(spacing: 20) {
                                switch selectedCalculatorType {
                                case .bmi:
                                    BMIStatisticsView(
                                        history: filteredHistory,
                                        timeRange: selectedTimeRange
                                    )
                                    .frame(width: min(availableWidth - 32, 600))
                                    .padding(.horizontal, 16)
                                case .calories:
                                    CaloriesStatisticsView(
                                        history: filteredHistory,
                                        timeRange: selectedTimeRange
                                    )
                                    .frame(width: min(availableWidth - 32, 600))
                                    .padding(.horizontal, 16)
                                case .macros:
                                    MacrosStatisticsViewWrapper(
                                        history: filteredHistory,
                                        timeRange: selectedTimeRange,
                                        width: min(availableWidth - 32, 600)
                                    )
                                    .padding(.horizontal, 16)
                                case .water:
                                    WaterStatisticsView(
                                        history: filteredHistory,
                                        timeRange: selectedTimeRange
                                    )
                                    .frame(width: min(availableWidth - 32, 600))
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.vertical, 16)
                        }
                    }
                }
                .navigationTitle("Statistics")
            }
        }
    }
    
    // Отфильтрованные записи по типу и времени
    private var filteredHistory: [CalculationHistory] {
        let calculatorTypeFilter = { (entry: CalculationHistory) -> Bool in
            entry.title == selectedCalculatorType.rawValue
        }
        
        let timeFilter = { (entry: CalculationHistory) -> Bool in
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
            return entry.date >= cutoffDate
        }
        
        return history.filter { calculatorTypeFilter($0) && timeFilter($0) }
    }
}

// Обертка для MacrosStatisticsView, которая помогает избежать конфликтов вложенных GeometryReader
struct MacrosStatisticsViewWrapper: View {
    let history: [CalculationHistory]
    let timeRange: TimeRange
    let width: CGFloat
    
    var body: some View {
        // Используем простую обертку с фиксированной шириной
        VStack {
            if history.isEmpty {
                EmptyStatisticsView(type: "Macros")
                    .frame(width: width)
            } else {
                // Карточка с основной статистикой
                MacrosStatsCard(dataPoints: getDataPoints())
                    .frame(width: width)
                    .padding(.bottom, 20)
                
                // График динамики макроэлементов
                MacrosChartView(dataPoints: getDataPoints())
                    .frame(width: width)
                    .padding(.bottom, 20)
                
                // Соотношение макроэлементов в последнем расчете
                if let lastPoint = getDataPoints().last {
                    MacrosDistributionView(dataPoint: lastPoint)
                        .frame(width: width)
                }
            }
        }
    }
    
    // Перенесенная логика из MacrosStatisticsView
    private func getDataPoints() -> [MacrosStatisticsView.MacroDataPoint] {
        let sortedEntries = history.sorted { $0.date < $1.date }
        
        return sortedEntries.compactMap { entry -> MacrosStatisticsView.MacroDataPoint? in
            if let macrosData = entry.macros {
                return MacrosStatisticsView.MacroDataPoint(
                    date: entry.date,
                    protein: macrosData.protein,
                    fat: macrosData.fat,
                    carbs: macrosData.carbs
                )
            } else {
                let dict = parseResult(entry.result)
                if let proteinStr = dict["protein"],
                   let fatStr = dict["fat"],
                   let carbsStr = dict["carbs"],
                   let protein = Double(proteinStr),
                   let fat = Double(fatStr),
                   let carbs = Double(carbsStr) {
                    return MacrosStatisticsView.MacroDataPoint(
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

// Общая модель для периода времени (используется во всех видах статистики)
enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case allTime = "All Time"
    
    var id: String { self.rawValue }
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .allTime: return 3650 // ~10 лет
        }
    }
}

// Общие компоненты для использования во всех видах статистики
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
    }
}

// Общее пустое состояние
struct EmptyStatisticsView: View {
    let type: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No \(type) Data Available")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text("Save some \(type) calculations to see your statistics and progress.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Заглушки для предварительного просмотра
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .preferredColorScheme(.dark)
    }
}
