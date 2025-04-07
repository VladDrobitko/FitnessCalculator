//
//  FitnessCalculatorApp.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 04/04/2025.
//
import SwiftUI
import SwiftData

@main
struct FitnessCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            FitnessCalculatorView()
        }
        .modelContainer(for: CalculationHistory.self)
    }
}
