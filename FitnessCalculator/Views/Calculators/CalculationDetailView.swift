//
//  CalculationDetailView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 07/04/2025.
//

import SwiftUI
import SwiftData

struct CalculationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    
    // Для работы жеста свайпа
    @GestureState private var dragOffset = CGSize.zero

    let entry: CalculationHistory

    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Заголовок
                    Text(entry.title)
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .padding(.bottom, 10)

                    // Дата
                    Text("Calculated on \(formatted(date: entry.date))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)

                    // Результат с визуализацией
                    switch CalculatorType(title: entry.title) {
                    case .calories:
                        caloriesDetailedView()
                    case .macros:
                        macrosDetailedView()
                    case .bmi:
                        bmiDetailedView()
                    case .water:
                        waterDetailedView()
                    }

                    Spacer()

                    Divider().background(Color.white)

                    // Объяснение
                    Group {
                        switch CalculatorType(title: entry.title) {
                        case .calories:
                            caloriesExplanation
                        case .macros:
                            macrosExplanation
                        case .bmi:
                            bmiExplanation
                        case .water:
                            waterExplanation
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Кнопка удаления
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .padding()
            .confirmationDialog("Are you sure you want to delete this entry?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(entry)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        // Добавляем жест свайпа справа налево для навигации назад
        .gesture(
            DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                // Проверяем, что свайп начался достаточно близко к левому краю
                if value.startLocation.x < 50 && value.translation.width > 100 {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        )
        // Альтернативный вариант с InteractivePopGestureRecognizer
        .onAppear {
            enableSwipeBackGesture()
        }
    }
    
    // Включаем стандартный жест свайпа назад
    private func enableSwipeBackGesture() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController,
              let navigationController = findNavigationController(in: rootViewController) else {
            return
        }
        
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // Рекурсивно ищем UINavigationController
    private func findNavigationController(in viewController: UIViewController) -> UINavigationController? {
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for child in viewController.children {
            if let navigationController = findNavigationController(in: child) {
                return navigationController
            }
        }
        
        return nil
    }

    // MARK: - Форматтеры и вспомогательные функции
    
    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    // MARK: - Detailed Views
    
    private func caloriesDetailedView() -> some View {
        // Сначала проверяем, есть ли структурированные данные
        if let caloriesData = entry.calories {
            return AnyView(
                VStack(spacing: 20) {
                    Text("Your result:")
                        .font(.headline)
                        .foregroundColor(.white)
                        
                    CaloriesProgressChart(
                        tdee: caloriesData.tdee,
                        goalCalories: caloriesData.goalCalories,
                        goal: Goal(rawValue: caloriesData.goal) ?? .maintain,
                        currentWeight: 75 // Стандартное значение для демонстрации
                    )
                }
            )
        } else {
            // Резервный вариант - парсинг строки
            let dict = parseResult(entry.result)
            
            if let tdeeStr = dict["tdee"],
               let goalCaloriesStr = dict["goalCalories"],
               let goalStr = dict["goal"],
               let tdee = Double(tdeeStr),
               let goalCalories = Double(goalCaloriesStr),
               let goal = Goal(rawValue: goalStr) {
                return AnyView(
                    VStack(spacing: 20) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        CaloriesProgressChart(
                            tdee: tdee,
                            goalCalories: goalCalories,
                            goal: goal,
                            currentWeight: 75 // Примерный вес
                        )
                    }
                )
            } else {
                return AnyView(
                    VStack(spacing: 10) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        Text(entry.result)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }
                )
            }
        }
    }
    
    private func macrosDetailedView() -> some View {
        // Сначала проверяем структурированные данные
        if let macrosData = entry.macros {
            return AnyView(
                VStack(spacing: 20) {
                    Text("Your result:")
                        .font(.headline)
                        .foregroundColor(.white)
                        
                    MacrosPieChart(
                        protein: macrosData.protein,
                        fat: macrosData.fat,
                        carbs: macrosData.carbs
                    )
                }
            )
        } else {
            // Резервный вариант - парсинг строки
            let dict = parseResult(entry.result)
            
            if let proteinStr = dict["protein"],
               let fatStr = dict["fat"],
               let carbsStr = dict["carbs"],
               let protein = Double(proteinStr),
               let fat = Double(fatStr),
               let carbs = Double(carbsStr) {
                return AnyView(
                    VStack(spacing: 20) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        MacrosPieChart(
                            protein: protein,
                            fat: fat,
                            carbs: carbs
                        )
                    }
                )
            } else {
                return AnyView(
                    VStack(spacing: 10) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        Text(entry.result)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }
                )
            }
        }
    }
    
    private func bmiDetailedView() -> some View {
        // Сначала проверяем структурированные данные
        if let bmiData = entry.bmi {
            return AnyView(
                VStack(spacing: 20) {
                    Text("Your result:")
                        .font(.headline)
                        .foregroundColor(.white)
                        
                    BMIScaleView(bmi: bmiData.bmi)
                }
            )
        } else {
            // Резервный вариант - парсинг строки
            let dict = parseResult(entry.result)
            
            if let bmiStr = dict["bmi"], let bmi = Double(bmiStr) {
                return AnyView(
                    VStack(spacing: 20) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        BMIScaleView(bmi: bmi)
                    }
                )
            } else if let bmi = Double(entry.result) {
                return AnyView(
                    VStack(spacing: 20) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        BMIScaleView(bmi: bmi)
                    }
                )
            } else {
                return AnyView(
                    VStack(spacing: 10) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        Text(entry.result)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }
                )
            }
        }
    }
    
    private func waterDetailedView() -> some View {
        // Сначала проверяем структурированные данные
        if let waterData = entry.water {
            return AnyView(
                VStack(spacing: 20) {
                    Text("Your result:")
                        .font(.headline)
                        .foregroundColor(.white)
                        
                    WaterGlassDiagram(dailyIntake: waterData.dailyIntake)
                }
            )
        } else {
            // Резервный вариант - парсинг строки
            let dict = parseResult(entry.result)
            
            if let waterStr = dict["result"], let water = Double(waterStr) {
                return AnyView(
                    VStack(spacing: 20) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        WaterGlassDiagram(dailyIntake: water)
                    }
                )
            } else if let water = Double(entry.result) {
                return AnyView(
                    VStack(spacing: 20) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        WaterGlassDiagram(dailyIntake: water)
                    }
                )
            } else {
                return AnyView(
                    VStack(spacing: 10) {
                        Text("Your result:")
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        Text(entry.result)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }
                )
            }
        }
    }

    // MARK: - Объяснения для разных калькуляторов
    
    private var caloriesExplanation: some View {
        Text("""
        This is your estimated daily caloric need based on your age, gender, weight, height, and activity level.

        You can use this number to maintain your current weight. To lose or gain weight, adjust your intake accordingly (e.g., -500 kcal/day to lose ~0.5 kg/week).
        """)
        .font(.subheadline)
        .foregroundColor(.gray)
    }

    private var macrosExplanation: some View {
        Text("""
        Your macronutrients (protein, fats, and carbs) are based on standard percentage splits from your total calorie needs.

        Use this to guide your meal planning, ensuring balanced nutrition based on your goal.
        """)
        .font(.subheadline)
        .foregroundColor(.gray)
    }

    private var waterExplanation: some View {
        Text("""
        Your recommended daily water intake depends on your weight and activity level.

        Staying hydrated supports energy, performance, and overall health.
        """)
        .font(.subheadline)
        .foregroundColor(.gray)
    }

    private var bmiExplanation: some View {
        Text("""
        BMI helps classify your body weight status based on height and weight.

        Use it as a general guideline, but remember that it doesn't account for muscle mass or body composition.
        """)
        .font(.subheadline)
        .foregroundColor(.gray)
    }
}

#Preview {
    // Примеры для предпросмотра с различными типами данных
    Group {
        CalculationDetailView(entry: CalculationHistory(
            title: "Calories",
            result: "tdee=2500;goalCalories=2200;goal=maintain"
        ))
        
        CalculationDetailView(entry: CalculationHistory(
            title: "BMI",
            result: "bmi=24.5"
        ))
        
        CalculationDetailView(entry: CalculationHistory(
            title: "Water Intake",
            result: "result=2.5"
        ))
        
        CalculationDetailView(entry: CalculationHistory(
            title: "Macros",
            result: "protein=150;fat=70;carbs=250"
        ))
    }
}
