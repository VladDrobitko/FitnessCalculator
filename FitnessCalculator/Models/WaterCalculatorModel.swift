//
//  WaterCalculatorModel.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//
import Foundation

struct WaterCalculatorModel {
    var weight: Double
    var gender: Gender // Добавляем пол
    var activityLevel: ActivityLevel // Используем перечисление вместо Double
    var climate: ClimateType // Добавляем учет климата

    // Рассчитываем рекомендуемое потребление воды
    func calculateWaterIntake() -> Double {
        // Базовое потребление в зависимости от пола
        // Для мужчин ~35 мл/кг, для женщин ~31 мл/кг
        let baseIntake = gender == .male ? (weight * 0.035) : (weight * 0.031)
        
        // Добавляем корректировку на активность
        var adjustedIntake = baseIntake
        
        switch activityLevel {
        case .sedentary:
            // Без изменений
            break
        case .lightlyActive:
            adjustedIntake += 0.3 // +300 мл
        case .moderatelyActive:
            adjustedIntake += 0.5 // +500 мл
        case .veryActive:
            adjustedIntake += 0.7 // +700 мл
        case .extraActive:
            adjustedIntake += 1.0 // +1000 мл
        }
        
        // Учитываем климат
        switch climate {
        case .temperate:
            // Без изменений
            break
        case .hot:
            adjustedIntake *= 1.1 // +10%
        case .humid:
            adjustedIntake *= 1.15 // +15%
        case .dry:
            adjustedIntake *= 1.05 // +5%
        }
        
        return adjustedIntake
    }
}

// Добавляем перечисление для типа климата
enum ClimateType: String, CaseIterable, Identifiable {
    case temperate = "Temperate"
    case hot = "Hot"
    case humid = "Humid"
    case dry = "Dry"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .temperate: return "Normal/Temperate"
        case .hot: return "Hot"
        case .humid: return "Hot & Humid"
        case .dry: return "Dry"
        }
    }
}

