//
//  MacroCalculatorModel.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//

import Foundation

struct MacroResult {
    let protein: Int   // in grams
    let fat: Int       // in grams
    let carbs: Int     // in grams
    let description: String
}

enum MacroGoal: String, CaseIterable, Identifiable {
    case maintain, lose, gain
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .maintain: return "Maintain"
        case .lose: return "Lose Weight"
        case .gain: return "Gain Muscle"
        }
    }
}

struct MacroCalculatorModel {
    let totalCalories: Int
    let goal: MacroGoal
    
    func calculateMacros() -> MacroResult {
        // Percentages based on standard macro splits
        // These can be adjusted if needed
        let (proteinRatio, fatRatio, carbRatio): (Double, Double, Double) = {
            switch goal {
            case .maintain:
                return (0.30, 0.25, 0.45)
            case .lose:
                return (0.40, 0.30, 0.30)
            case .gain:
                return (0.30, 0.20, 0.50)
            }
        }()
        
        let proteinCalories = Double(totalCalories) * proteinRatio
        let fatCalories = Double(totalCalories) * fatRatio
        let carbCalories = Double(totalCalories) * carbRatio
        
        let proteinGrams = Int(proteinCalories / 4)  // 1g protein = 4 kcal
        let fatGrams = Int(fatCalories / 9)          // 1g fat = 9 kcal
        let carbGrams = Int(carbCalories / 4)        // 1g carb = 4 kcal
        
        return MacroResult(
            protein: proteinGrams,
            fat: fatGrams,
            carbs: carbGrams,
            description: goal.description
        )
    }
}

