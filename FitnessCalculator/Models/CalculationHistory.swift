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
    var result: String
    var date: Date

    init(title: String, result: String, date: Date = .now) {
        self.title = title
        self.result = result
        self.date = date
    }
}

