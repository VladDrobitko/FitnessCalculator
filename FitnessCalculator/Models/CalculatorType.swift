//
//  CalculatorType.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//

import Foundation

enum CalculatorType: String {
    case calories = "Calories"
    case macros = "Macros"
    case bmi = "BMI"
    case water = "Water Intake"

    init(title: String) {
        self = CalculatorType(rawValue: title) ?? .calories
    }
}
