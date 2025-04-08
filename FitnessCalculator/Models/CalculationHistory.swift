//
//  FitnessCalculatorViewModel.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 04/04/2025.
//

import Foundation
import SwiftData

@Model
class CalculationHistory {
    var title: String
    var date: Date
    
    // Текстовый результат (для обратной совместимости)
    var result: String
    
    // Поля для разных типов калькуляторов
    // Эти поля хранятся как Data, но представляют структуры
    var caloriesData: Data?
    var macrosData: Data?
    var bmiData: Data?
    var waterData: Data?
    
    init(title: String, result: String, date: Date = .now) {
        self.title = title
        self.result = result
        self.date = date
        
        // Парсим результат и заполняем соответствующие структуры
        parseAndPopulateData()
    }
    
    // Удобные вычисляемые свойства для доступа к структурированным данным
    var calories: CaloriesData? {
        get {
            guard let data = caloriesData else { return nil }
            return try? JSONDecoder().decode(CaloriesData.self, from: data)
        }
        set {
            if let newValue = newValue {
                caloriesData = try? JSONEncoder().encode(newValue)
            } else {
                caloriesData = nil
            }
        }
    }
    
    var macros: MacrosData? {
        get {
            guard let data = macrosData else { return nil }
            return try? JSONDecoder().decode(MacrosData.self, from: data)
        }
        set {
            if let newValue = newValue {
                macrosData = try? JSONEncoder().encode(newValue)
            } else {
                macrosData = nil
            }
        }
    }
    
    var bmi: BMIData? {
        get {
            guard let data = bmiData else { return nil }
            return try? JSONDecoder().decode(BMIData.self, from: data)
        }
        set {
            if let newValue = newValue {
                bmiData = try? JSONEncoder().encode(newValue)
            } else {
                bmiData = nil
            }
        }
    }
    
    var water: WaterData? {
        get {
            guard let data = waterData else { return nil }
            return try? JSONDecoder().decode(WaterData.self, from: data)
        }
        set {
            if let newValue = newValue {
                waterData = try? JSONEncoder().encode(newValue)
            } else {
                waterData = nil
            }
        }
    }
    
    func parseAndPopulateData() {
        let dict = parseResult(result)
        
        switch title {
        case "Calories":
            if let tdeeStr = dict["tdee"],
               let goalCaloriesStr = dict["goalCalories"],
               let goalStr = dict["goal"],
               let tdee = Double(tdeeStr),
               let goalCalories = Double(goalCaloriesStr) {
                let caloriesData = CaloriesData(
                    tdee: tdee,
                    goalCalories: goalCalories,
                    goal: goalStr
                )
                self.calories = caloriesData
            }
            
        case "BMI":
            if let bmiStr = dict["bmi"], let bmi = Double(bmiStr) {
                let bmiData = BMIData(bmi: bmi)
                self.bmi = bmiData
            }
            
        case "Water Intake":
            if let waterStr = dict["result"], let water = Double(waterStr) {
                let waterData = WaterData(dailyIntake: water)
                self.water = waterData
            }
            
        case "Macros":
            if let proteinStr = dict["protein"],
               let fatStr = dict["fat"],
               let carbsStr = dict["carbs"],
               let protein = Double(proteinStr),
               let fat = Double(fatStr),
               let carbs = Double(carbsStr) {
                let macrosData = MacrosData(
                    protein: protein,
                    fat: fat,
                    carbs: carbs
                )
                self.macros = macrosData
            }
            
        default:
            break
        }
    }
    
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

// Вложенные структуры для хранения данных
struct CaloriesData: Codable {
    var tdee: Double
    var goalCalories: Double
    var goal: String
}

struct MacrosData: Codable {
    var protein: Double
    var fat: Double
    var carbs: Double
}

struct BMIData: Codable {
    var bmi: Double
}

struct WaterData: Codable {
    var dailyIntake: Double
}

