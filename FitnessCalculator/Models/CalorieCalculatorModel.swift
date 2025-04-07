//
//  CalorieCalculatorModel.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//

import Foundation

enum Gender {
    case male
    case female
}

enum ActivityLevel: Double, CaseIterable, Identifiable {
    case sedentary = 1.2            // Little or no exercise
    case lightlyActive = 1.375      // Light exercise (1–3 days/week)
    case moderatelyActive = 1.55    // Moderate exercise (3–5 days/week)
    case veryActive = 1.725         // Hard exercise (6–7 days/week)
    case extraActive = 1.9          // Very hard exercise (twice/day)

    var id: Double { self.rawValue }

    var description: String {
        switch self {
        case .sedentary: return "Little or no exercise"
        case .lightlyActive: return "1–3 workouts/week"
        case .moderatelyActive: return "3–5 workouts/week"
        case .veryActive: return "6–7 workouts/week"
        case .extraActive: return "2 times/day or physical job"
        }
    }
}

enum Goal: String, CaseIterable, Identifiable  {
    case maintain
    case lose
    case gain
    
    var id: String { rawValue }

    var description: String {
        switch self {
        case .maintain: return "Maintain weight"
        case .lose: return "Lose weight"
        case .gain: return "Gain muscle"
        }
    }
}

struct CalorieCalculatorModel {
    var gender: Gender
    var age: Int
    var height: Double  // cm
    var weight: Double  // kg
    var activityLevel: ActivityLevel
    var goal: Goal

    func calculateCalories() -> (tdee: Double, goalAdjusted: Double, goalDescription: String) {
        // BMR (Basal Metabolic Rate)
        let bmr: Double
        if gender == .male {
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }

        let tdee = bmr * activityLevel.rawValue
        let goalCalories: Double

        switch goal {
        case .maintain:
            goalCalories = tdee
        case .lose:
            goalCalories = tdee * 0.85 // 15% deficit
        case .gain:
            goalCalories = tdee * 1.15 // 15% surplus
        }

        return (tdee, goalCalories, goal.description)
    }
}

