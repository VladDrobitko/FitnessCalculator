//
//  FitnessCalculatorApp.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 04/04/2025.
//
import SwiftUI
import SwiftData

@main
struct FitFormulaApp: App {
    
    @State private var isShowingSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Основной контент приложения
                MainTabView()
                    .opacity(isShowingSplash ? 0 : 1) // Скрываем основной контент во время сплеш-скрина
                
                // Сплеш-скрин поверх основного контента
                if isShowingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.5), value: isShowingSplash)
                        .onAppear {
                            // Задержка перед скрытием
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation {
                                    isShowingSplash = false
                                }
                            }
                        }
                        .zIndex(1) // Гарантируем, что сплеш будет поверх всего
                }
            }
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

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 265, height: 190)
        }
        .edgesIgnoringSafeArea(.all) // Заполняем весь экран
    }
}
