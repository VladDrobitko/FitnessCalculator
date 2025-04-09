//
//  WaterStatisticsView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI
import Charts

struct WaterStatisticsView: View {
    let history: [CalculationHistory]
    let timeRange: TimeRange
    
    // Структура данных для воды
    struct WaterDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let waterIntake: Double // в литрах
        
        var glasses: Int {
            Int(waterIntake * 1000 / 250) // стаканы по 250 мл
        }
    }
    
    // Преобразуем историю в точки данных
    private var dataPoints: [WaterDataPoint] {
        let sortedEntries = history.sorted { $0.date < $1.date }
        
        return sortedEntries.compactMap { entry -> WaterDataPoint? in
            if let waterData = entry.water {
                return WaterDataPoint(date: entry.date, waterIntake: waterData.dailyIntake)
            } else {
                let dict = parseResult(entry.result)
                if let waterStr = dict["result"], let water = Double(waterStr) {
                    return WaterDataPoint(date: entry.date, waterIntake: water)
                }
            }
            return nil
        }
    }
    
    var body: some View {
        if dataPoints.isEmpty {
            EmptyStatisticsView(type: "Water Intake")
        } else {
            ScrollView {
                VStack(spacing: 24) {
                    // Основная статистика
                    WaterStatsCard(dataPoints: dataPoints)
                    
                    // График потребления воды
                    WaterChartSimpleView(dataPoints: dataPoints)
                    
                    // Визуализация стаканов
                    WaterGlassView(dataPoint: dataPoints.last!)
                }
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

// Карточка с основной статистикой по воде
struct WaterStatsCard: View {
    let dataPoints: [WaterStatisticsView.WaterDataPoint]
    
    // Вычисляем основные метрики
    private var currentValue: Double {
        dataPoints.last?.waterIntake ?? 0
    }
    
    private var averageValue: Double {
        let sum = dataPoints.reduce(0) { $0 + $1.waterIntake }
        return dataPoints.isEmpty ? 0 : sum / Double(dataPoints.count)
    }
    
    private var minValue: Double {
        dataPoints.min(by: { $0.waterIntake < $1.waterIntake })?.waterIntake ?? 0
    }
    
    private var maxValue: Double {
        dataPoints.max(by: { $0.waterIntake < $1.waterIntake })?.waterIntake ?? 0
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Water Intake Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            // Основные показатели
            HStack(spacing: 20) {
                StatCard(title: "Current", value: String(format: "%.1f L", currentValue), color: .blue)
                StatCard(title: "Average", value: String(format: "%.1f L", averageValue), color: .blue)
                StatCard(title: "Entries", value: "\(dataPoints.count)", color: .gray)
            }
            
            // Дополнительные показатели
            HStack(spacing: 20) {
                StatCard(title: "Min", value: String(format: "%.1f L", minValue), color: .gray)
                StatCard(title: "Max", value: String(format: "%.1f L", maxValue), color: .gray)
                
                // Последние стаканы
                if let lastPoint = dataPoints.last {
                    StatCard(title: "Glasses", value: "\(lastPoint.glasses)", color: .blue)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Упрощенный график потребления воды
struct WaterChartSimpleView: View {
    let dataPoints: [WaterStatisticsView.WaterDataPoint]
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Water Intake Timeline")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            Chart {
                ForEach(dataPoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Water", point.waterIntake)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Water", point.waterIntake)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(50)
                }
                
                // Рекомендуемый минимум
                RuleMark(y: .value("Min Recommended", 1.5))
                    .foregroundStyle(.blue.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
            .frame(height: 260)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Визуализация стакана
struct WaterGlassView: View {
    let dataPoint: WaterStatisticsView.WaterDataPoint
    
    @State private var animateWave = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Daily Water Intake")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                // Стакан
                ZStack(alignment: .bottom) {
                    // Стакан
                    CustomGlass()
                        .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                        .frame(width: 100, height: 140)
                    
                    // Вода в стакане
                    let fillPercentage = min(1.0, Double(dataPoint.glasses) / 8.0)
                    
                    CustomGlassWater(fillPercentage: fillPercentage)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 100, height: 140)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateWave)
                }
                .frame(height: 160)
                
                Spacer()
                
                // Информация
                VStack(alignment: .leading, spacing: 12) {
                    // Стаканы
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Current intake:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("\(dataPoint.glasses) glasses")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                        
                        Text("(\(String(format: "%.1f", dataPoint.waterIntake)) liters)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Рекомендация
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Recommended:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("8 glasses")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.gray)
                        
                        Text("(2.0 liters)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading)
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(10)
            
            // Советы
            HydrationTipsView()
                .padding(.top, 10)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .onAppear {
            animateWave = true
        }
    }
}

// Советы по гидратации
struct HydrationTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hydration Tips")
                .font(.subheadline)
                .foregroundColor(.white)
            
            TipRow(text: "Start your day with a glass of water")
            TipRow(text: "Carry a water bottle with you")
            TipRow(text: "Set reminders to drink regularly")
            TipRow(text: "Drink a glass before each meal")
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
    }
}
