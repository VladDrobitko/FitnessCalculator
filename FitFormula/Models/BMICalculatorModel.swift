//
//  BMICalculatorModel.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//

import Foundation

struct BMICalculatorModel {
    var weight: Double // в килограммах
    var height: Double // в метрах
    
    func calculateBMI() -> Double {
        return weight / (height * height)
    }
    
    func getBMICategory() -> String {
        let bmi = calculateBMI()
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<24.9:
            return "Normal weight"
        case 25..<29.9:
            return "Overweight"
        default:
            return "Obesity"
        }
    }
}

