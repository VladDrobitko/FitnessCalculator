//
//  CalculatorInputView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 04/04/2025.
//
import SwiftUI
import SwiftData

struct CalculatorCaloriesView: View {
    let calculatorType: String
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    
    @State private var isPressed = false
    @State private var isSavePressed = false
    @FocusState private var isTextFieldFocused: Bool

    // Inputs
    @State private var gender: Gender = .male
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var activityLevel: ActivityLevel = .sedentary
    @State private var goal: Goal = .maintain

    // Result
    @State private var resultText: String = ""
    @State private var tdee: Double = 0
    @State private var goalCalories: Double = 0

    // Info block
    @State private var showFullInfo = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Calorie Calculator")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Gender
                    HStack {
                        Text("Gender:")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Gender", selection: $gender) {
                            Text("Male").tag(Gender.male)
                            Text("Female").tag(Gender.female)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
                    
                    // Age
                    HStack {
                        Text("Age:")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("Years", text: $age)
                            .focused($isTextFieldFocused)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    // Height
                    HStack {
                        Text("Height (cm):")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("cm", text: $height)
                            .focused($isTextFieldFocused)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    // Weight
                    HStack {
                        Text("Weight (kg):")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("kg", text: $weight)
                            .focused($isTextFieldFocused)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    // Activity Level
                    HStack() {
                        Text("Activity Level:")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Activity Level", selection: $activityLevel) {
                            ForEach(ActivityLevel.allCases) { level in
                                Text(level.description).tag(level)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                    }
                    
                    // Goal
                    VStack(alignment: .leading) {
                        Text("Goal:")
                            .foregroundColor(.white)
                        Picker("Goal", selection: $goal) {
                            Text("Maintain").tag(Goal.maintain)
                            Text("Lose").tag(Goal.lose)
                            Text("Gain").tag(Goal.gain)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Calculate button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                        calculate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isPressed = false
                        }
                    }) {
                        Text("Calculate")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .scaleEffect(isPressed ? 0.97 : 1.0)
                    }
                    
                    
                    
                    
                    
                    // В CalculatorCaloriesView добавить:
                    
                    
                    // Заменяем блок result + save button:
                    if !resultText.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            if let currentWeight = Double(weight) {
                                CaloriesProgressChart(
                                    tdee: tdee,
                                    goalCalories: goalCalories,
                                    goal: goal,
                                    currentWeight: currentWeight
                                )
                            }
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isSavePressed = true
                                }
                                
                                // Форматируем результат для ключ-значение (оставляем для совместимости)
                                let formattedResult = "tdee=\(tdee);goalCalories=\(goalCalories);goal=\(goal.rawValue)"
                                
                                // Создаем запись истории
                                let historyEntry = CalculationHistory(title: "Calories", result: formattedResult)
                                
                                // Явно устанавливаем структурированные данные
                                historyEntry.calories = CaloriesData(
                                    tdee: tdee,
                                    goalCalories: goalCalories,
                                    goal: goal.rawValue
                                )
                                
                                // Сохраняем запись
                                modelContext.insert(historyEntry)
                                dismiss()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isSavePressed = false
                                }
                            }) {
                                Text("Save Result")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.top, 12)
                                    .scaleEffect(isSavePressed ? 0.97 : 1.0)
                            }
                        }
                        
                    }
                    
                    
                    
                    
                    Spacer()
                    
                    // Explanation block
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How we calculate calories?")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ZStack(alignment: .bottom) {
                            Text("""
    We use the Mifflin-St Jeor formula to estimate your Basal Metabolic Rate (BMR), which is the number of calories your body needs at rest. This is adjusted using your selected activity level to calculate Total Daily Energy Expenditure (TDEE). Then, depending on your goal, the final number is:
    
    • Maintain: TDEE  
    • Lose weight: TDEE - 15%  
    • Gain weight: TDEE + 15%
    """)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(showFullInfo ? nil : 4)
                            .animation(.easeInOut, value: showFullInfo)
                            
                            if !showFullInfo {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.black]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 60)
                                .allowsHitTesting(false)
                            }
                        }
                        
                        Button(action: {
                            withAnimation {
                                showFullInfo.toggle()
                            }
                        }) {
                            Text(showFullInfo ? "Hide" : "Read more")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false
                    }
                }
            }
        }
    }

    private func calculate() {
        // Обрабатываем возможные запятые вместо точек и очищаем от пробелов
        let cleanHeight = height.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        let cleanWeight = weight.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        let cleanAge = age.trimmingCharacters(in: .whitespaces)
        
        // Проверяем, что возраст - целое число
        guard let age = Int(cleanAge) else {
            resultText = "Please enter a valid age."
            return
        }
        
        // Проверяем, что рост и вес - числа с плавающей точкой
        guard let height = Double(cleanHeight),
              let weight = Double(cleanWeight) else {
            resultText = "Please enter valid height and weight."
            return
        }
        
        // Проверяем диапазоны значений
        guard age > 0 && age < 120 else {
            resultText = "Age should be between 1 and 120."
            return
        }
        
        guard height > 0 && height < 300 else {
            resultText = "Height should be between 1 and 300 cm."
            return
        }
        
        guard weight > 0 && weight < 500 else {
            resultText = "Weight should be between 1 and 500 kg."
            return
        }

        let model = CalorieCalculatorModel(
            gender: gender,
            age: age,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            goal: goal
        )

        let result = model.calculateCalories()
        tdee = result.tdee
        goalCalories = result.goalAdjusted

        resultText = """
        TDEE (Total Daily Energy Expenditure): \(Int(tdee)) kcal/day
        Goal (\(result.goalDescription)): \(Int(goalCalories)) kcal/day
        """
    }
}

struct CalculatorCaloriesView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CalculatorCaloriesView(calculatorType: "Calories") { title, result in
                print("Result for \(title): \(result)")
            }
        }
        .preferredColorScheme(.dark)
    }
}

