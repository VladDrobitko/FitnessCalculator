//
//  BMIStatisticsView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI
import Charts

struct BMIStatisticsView: View {
    let history: [CalculationHistory]
    let timeRange: TimeRange
    
    // Структура данных для графика
    struct BMIDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let bmi: Double
        
        var category: String {
            if bmi < 18.5 {
                return "Underweight"
            } else if bmi < 24.9 {
                return "Normal"
            } else if bmi < 29.9 {
                return "Overweight"
            } else {
                return "Obesity"
            }
        }
        
        var color: Color {
            if bmi < 18.5 {
                return .blue
            } else if bmi < 24.9 {
                return .green
            } else if bmi < 29.9 {
                return .orange
            } else {
                return .red
            }
        }
    }
    
    // Преобразование истории в данные для графика
    private var dataPoints: [BMIDataPoint] {
        // Сортируем по дате и преобразуем данные
        let sortedEntries = history.sorted { $0.date < $1.date }
        
        return sortedEntries.compactMap { entry -> BMIDataPoint? in
            // Пытаемся извлечь структурированные данные
            if let bmiData = entry.bmi {
                return BMIDataPoint(date: entry.date, bmi: bmiData.bmi)
            } else {
                // Резервный вариант - извлекаем из строки
                let dict = parseResult(entry.result)
                if let bmiStr = dict["bmi"], let bmi = Double(bmiStr) {
                    return BMIDataPoint(date: entry.date, bmi: bmi)
                }
            }
            return nil
        }
    }
    
    var body: some View {
        if dataPoints.isEmpty {
            EmptyStatisticsView(type: "BMI")
        } else {
            VStack(spacing: 24) {
                // Основная статистика
                BMIStatsCard(dataPoints: dataPoints)
                
                // График BMI
                BMIChartView(dataPoints: dataPoints)
                
                // Таблица истории BMI
                BMIHistoryTable(dataPoints: dataPoints)
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

// Карточка с основной статистикой BMI
struct BMIStatsCard: View {
    let dataPoints: [BMIStatisticsView.BMIDataPoint]
    
    private var currentBMI: Double {
        dataPoints.last?.bmi ?? 0
    }
    
    private var averageBMI: Double {
        let sum = dataPoints.reduce(0) { $0 + $1.bmi }
        return dataPoints.isEmpty ? 0 : sum / Double(dataPoints.count)
    }
    
    private var minBMI: Double {
        dataPoints.min(by: { $0.bmi < $1.bmi })?.bmi ?? 0
    }
    
    private var maxBMI: Double {
        dataPoints.max(by: { $0.bmi < $1.bmi })?.bmi ?? 0
    }
    
    private var totalChange: Double {
        guard let first = dataPoints.first?.bmi, let last = dataPoints.last?.bmi else { return 0 }
        return last - first
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("BMI Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            // Основные показатели
            HStack(spacing: 20) {
                StatCard(title: "Current", value: String(format: "%.1f", currentBMI), color: .green)
                StatCard(title: "Average", value: String(format: "%.1f", averageBMI), color: .blue)
                StatCard(title: "Change", value: "\(totalChange > 0 ? "+" : "")\(String(format: "%.1f", totalChange))",
                         color: totalChange > 0 ? .orange : .green)
            }
            
            // Дополнительные показатели
            HStack(spacing: 20) {
                StatCard(title: "Min", value: String(format: "%.1f", minBMI), color: .blue)
                StatCard(title: "Max", value: String(format: "%.1f", maxBMI), color: .red)
                StatCard(title: "Entries", value: "\(dataPoints.count)", color: .gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// График BMI
struct BMIChartView: View {
    let dataPoints: [BMIStatisticsView.BMIDataPoint]
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("BMI Timeline")
                .font(.headline)
                .foregroundColor(.white)
            
            ZStack {
                // Полосы категорий BMI на заднем плане
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.red.opacity(0.1))
                        .frame(height: 40)
                    Rectangle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(height: 30)
                    Rectangle()
                        .fill(Color.green.opacity(0.1))
                        .frame(height: 30)
                    Rectangle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 40)
                }
                
                Chart {
                    ForEach(dataPoints) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("BMI", point.bmi)
                        )
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("BMI", point.bmi)
                        )
                        .foregroundStyle(point.color)
                        .symbolSize(50)
                    }
                    
                    // Добавляем горизонтальные линии для границ категорий
                    RuleMark(y: .value("Underweight", 18.5))
                        .foregroundStyle(.blue.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    
                    RuleMark(y: .value("Normal", 24.9))
                        .foregroundStyle(.green.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    
                    RuleMark(y: .value("Overweight", 29.9))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                .chartYScale(domain: 16...35)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .frame(height: 260)
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(10)
            
            // Легенда для категорий BMI
            HStack(spacing: 20) {
                CategoryLabel(color: .blue, text: "Underweight (<18.5)")
                CategoryLabel(color: .green, text: "Normal (18.5-24.9)")
                CategoryLabel(color: .orange, text: "Overweight (25-29.9)")
                CategoryLabel(color: .red, text: "Obesity (≥30)")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Метка категории для легенды
struct CategoryLabel: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// Таблица истории BMI
struct BMIHistoryTable: View {
    let dataPoints: [BMIStatisticsView.BMIDataPoint]
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("BMI History")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                // Заголовок таблицы
                HStack {
                    Text("Date")
                        .fontWeight(.medium)
                        .frame(width: 80, alignment: .leading)
                    Text("BMI")
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .trailing)
                    Text("Category")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Change")
                        .fontWeight(.medium)
                        .frame(width: 70, alignment: .trailing)
                }
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color.white.opacity(0.1))
                
                // Строки таблицы
                ForEach(0..<dataPoints.count, id: \.self) { index in
                    let current = dataPoints[index]
                    let previous = index > 0 ? dataPoints[index - 1] : nil
                    let change = previous != nil ? current.bmi - previous!.bmi : 0
                    
                    HStack {
                        Text(current.date, style: .date)
                            .font(.subheadline)
                            .frame(width: 80, alignment: .leading)
                        
                        Text(String(format: "%.1f", current.bmi))
                            .font(.subheadline)
                            .frame(width: 50, alignment: .trailing)
                        
                        Text(current.category)
                            .font(.subheadline)
                            .foregroundColor(current.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if index > 0 {
                            Text("\(change > 0 ? "+" : "")\(String(format: "%.1f", change))")
                                .font(.subheadline)
                                .foregroundColor(change > 0 ? .orange : (change < 0 ? .green : .gray))
                                .frame(width: 70, alignment: .trailing)
                        } else {
                            Text("-")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: 70, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(index % 2 == 0 ? Color.clear : Color.white.opacity(0.03))
                }
            }
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}


// Добавьте этот код в конец вашего файла BMIStatisticsView.swift

// Превью для BMIStatisticsView
struct BMIStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Создаем тестовые данные для превью
            BMIStatisticsView(
                history: [
                    createSampleBMIHistory(bmi: 26.7, daysAgo: 30),
                    createSampleBMIHistory(bmi: 25.8, daysAgo: 20),
                    createSampleBMIHistory(bmi: 24.9, daysAgo: 10),
                    createSampleBMIHistory(bmi: 23.5, daysAgo: 0)
                ],
                timeRange: .month
            )
            .padding()
        }
        .preferredColorScheme(.dark)
        // Ограничиваем размер для превью, чтобы видеть проблемы с размерами
        .previewLayout(.fixed(width: 375, height: 800))
    }
    
    // Вспомогательная функция для создания тестовых данных
    static func createSampleBMIHistory(bmi: Double, daysAgo: Int) -> CalculationHistory {
        let entry = CalculationHistory(
            title: "BMI",
            result: "bmi=\(bmi)"
        )
        
        // Устанавливаем дату в прошлом
        if daysAgo > 0 {
            entry.date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        }
        
        // Устанавливаем структурированные данные
        entry.bmi = BMIData(bmi: bmi)
        
        return entry
    }
}
