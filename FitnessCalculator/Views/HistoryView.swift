//
//  HistoryView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//
import SwiftUI

struct HistoryView: View {
    let history: [CalculationHistory]
    let deleteItem: (CalculationHistory) -> Void

    var body: some View {
        VStack {
            Text("Calculation History")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            
            List {
                ForEach(history) { entry in
                    NavigationLink(destination: CalculationDetailView(entry: entry)) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(entry.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Image(systemName: getIcon(for: entry.title))
                                    .foregroundColor(.green)
                                    .font(.system(size: 16))
                            }
                            Text(formatResult(entry.title, entry.result))
                                .foregroundColor(.gray)
                            Text(entry.date, style: .date)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        .padding(.leading, 0)
                        .listRowBackground(Color.clear)
                        
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteItem(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(12)
        .padding(.trailing)
    }

    func getIcon(for title: String) -> String {
        switch title {
        case "Calories": return "flame.fill"
        case "Macros": return "chart.pie.fill"
        case "Water Intake": return "drop.fill"
        case "BMI": return "figure.stand"
        default: return "questionmark.circle"
        }
    }
    
    // Форматирование результата для читабельного отображения
    func formatResult(_ title: String, _ result: String) -> String {
        // Парсинг ключ-значений
        let dict = parseResult(result)
        
        switch title {
        case "Calories":
            if let tdeeStr = dict["tdee"], let goalCalStr = dict["goalCalories"],
               let tdee = Double(tdeeStr), let goalCal = Double(goalCalStr) {
                return "\(Int(tdee)) kcal → \(Int(goalCal)) kcal"
            }
            
        case "BMI":
            if let bmiStr = dict["bmi"], let bmi = Double(bmiStr) {
                let category = getBMICategory(bmi)
                return "\(String(format: "%.1f", bmi)) - \(category)"
            }
            
        case "Water Intake":
            if let waterStr = dict["result"], let water = Double(waterStr) {
                return "\(String(format: "%.1f", water)) L/day"
            }
            
        case "Macros":
            if let proteinStr = dict["protein"], let fatStr = dict["fat"], let carbsStr = dict["carbs"],
               let protein = Double(proteinStr), let fat = Double(fatStr), let carbs = Double(carbsStr) {
                return "P: \(Int(protein))g, F: \(Int(fat))g, C: \(Int(carbs))g"
            }
        default:
            break
        }
        
        // Если ничего не сработало, вернуть исходную строку
        return result
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
    
    // Получение категории BMI
    private func getBMICategory(_ bmi: Double) -> String {
        if bmi < 18.5 {
            return "Underweight"
        } else if bmi < 24.9 {
            return "Normal weight"
        } else if bmi < 29.9 {
            return "Overweight"
        } else {
            return "Obesity"
        }
    }
}

