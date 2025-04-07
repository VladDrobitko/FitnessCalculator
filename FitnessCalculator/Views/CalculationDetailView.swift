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

                    // Результат
                    Text("Your result:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Разные отображения в зависимости от типа калькулятора
                    Group {
                        switch CalculatorType(title: entry.title) {
                        case .calories:
                            caloriesResultView(result: entry.result)
                        case .macros:
                            macrosResultView(result: entry.result)
                        case .bmi:
                            bmiResultView(result: entry.result)
                        case .water:
                            waterResultView(result: entry.result)
                        }
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
    
    // MARK: - View для результатов
    
    // Остальной код без изменений...
    
    // MARK: - View для результатов калорий
    private func caloriesResultView(result: String) -> some View {
        let dict = parseResult(result)
        
        if let tdeeStr = dict["tdee"],
           let goalCaloriesStr = dict["goalCalories"],
           let goalStr = dict["goal"],
           let tdee = Double(tdeeStr),
           let goalCalories = Double(goalCaloriesStr),
           let goal = Goal(rawValue: goalStr) {
            return AnyView(tdeeAndGoalView(tdee: tdee, goalCalories: goalCalories, goal: goal))
        } else {
            // Попробуем просто отобразить результат, если он не в формате ключ-значение
            return AnyView(
                Text(result)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 16)
            )
        }
    }
    
    // MARK: - View для результатов ИМТ
    private func bmiResultView(result: String) -> some View {
        let dict = parseResult(result)
        
        if let bmiStr = dict["bmi"], let bmi = Double(bmiStr) {
            return AnyView(bmiInfoView(bmi: bmi))
        } else if let bmi = Double(result) {
            // Если результат - это просто число, интерпретируем как ИМТ
            return AnyView(bmiInfoView(bmi: bmi))
        } else {
            return AnyView(
                Text(result)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 16)
            )
        }
    }
    
    // MARK: - View для результатов воды
    private func waterResultView(result: String) -> some View {
        let dict = parseResult(result)
        
        if let waterStr = dict["result"], let water = Double(waterStr) {
            return AnyView(waterIntakeView(dailyWaterIntake: water))
        } else if let water = Double(result) {
            // Если результат - это просто число, интерпретируем как количество воды
            return AnyView(waterIntakeView(dailyWaterIntake: water))
        } else {
            return AnyView(
                Text(result)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 16)
            )
        }
    }
    
    // MARK: - View для результатов макросов
    private func macrosResultView(result: String) -> some View {
        let dict = parseResult(result)
        
        if let proteinStr = dict["protein"],
           let fatStr = dict["fat"],
           let carbsStr = dict["carbs"],
           let protein = Double(proteinStr),
           let fat = Double(fatStr),
           let carbs = Double(carbsStr) {
            return AnyView(macrosView(protein: protein, fat: fat, carbs: carbs))
        } else {
            // Если это не в нужном формате, просто отображаем текст
            return AnyView(
                Text(result)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 16)
            )
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

    // MARK: - View компоненты для отображения результатов
    
    private func tdeeAndGoalView(tdee: Double, goalCalories: Double, goal: Goal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("TDEE")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(Int(tdee)) kcal/day")
                .font(.title3)
                .bold()
                .foregroundColor(.white)

            Text("Goal (\(goal.description))")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 8)
            Text("\(Int(goalCalories)) kcal/day")
                .font(.title3)
                .bold()
                .foregroundColor(.green)
        }
        .padding(.top, 16)
    }

    private func bmiInfoView(bmi: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("BMI")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(String(format: "%.1f", bmi))")
                .font(.title3)
                .bold()
                .foregroundColor(.white)

            Text("Category")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 8)
            
            Text(bmiCategory(bmi: bmi))
                .font(.title3)
                .bold()
                .foregroundColor(.green)
        }
        .padding(.top, 16)
    }

    private func bmiCategory(bmi: Double) -> String {
        if bmi < 18.5 {
            return "Underweight"
        } else if bmi < 24.9 {
            return "Normal weight"
        } else if bmi < 29.9 {
            return "Overweight"
        } else {
            return "Obesity"
        }
    }

    private func waterIntakeView(dailyWaterIntake: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Recommended Water Intake")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(String(format: "%.1f", dailyWaterIntake)) L/day")
                .font(.title3)
                .bold()
                .foregroundColor(.white)
        }
        .padding(.top, 16)
    }
    
    private func macrosView(protein: Double, fat: Double, carbs: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Macronutrients")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Protein")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(Int(protein)) g")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fat")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(Int(fat)) g")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Carbs")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(Int(carbs)) g")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 8)
        }
        .padding(.top, 16)
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
