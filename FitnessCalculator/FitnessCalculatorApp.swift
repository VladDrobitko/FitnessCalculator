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

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [CalculationHistory.self]
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [CalculationHistory.self]
    }
}

struct CalculationHistoryMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self,
        willMigrate: { context in
            // Здесь мы получаем все существующие записи перед миграцией
            let fetchDescriptor = FetchDescriptor<CalculationHistory>()
            let oldRecords = try context.fetch(fetchDescriptor)
            
            // Сохраняем данные о записях для последующего восстановления
            for record in oldRecords {
                // Парсим и заполняем структурированные данные
                record.parseAndPopulateData()
            }
            
            try context.save()
        },
        didMigrate: { context in
            // Код выполняется после миграции схемы
            print("Миграция завершена успешно")
        }
    )
}
