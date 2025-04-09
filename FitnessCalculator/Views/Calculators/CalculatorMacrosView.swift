//
//  CalculatorMacrosView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//

import SwiftUI

struct CalculatorMacrosView: View {
    let calculatorType: String
    var onSave: (String, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isTextFieldFocused: Bool
    
    // Info block
    @State private var showFullInfo = false


    @State private var calories: String = ""
    @State private var goal: MacroGoal = .maintain
    @State private var result: MacroResult?
    @State private var showResult = false
    @State private var animateButton = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Macro Calculator")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Input - добавлен focused модификатор
                    HStack {
                        Text("Calories:")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("kcal", text: $calories)
                            .focused($isTextFieldFocused) // Вот эта строка была пропущена!
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    // Goal Picker
                    VStack(alignment: .leading) {
                        Text("Goal:")
                            .foregroundColor(.white)
                        Picker("Goal", selection: $goal) {
                            ForEach(MacroGoal.allCases) { g in
                                Text(g.description).tag(g)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Calculate Button
                    Button(action: {
                        withAnimation(.easeInOut) {
                            calculate()
                            showResult = true
                            animateButton = true
                            isTextFieldFocused = false // Скрываем клавиатуру при нажатии на кнопку
                        }
                        
                        // Reset animation after short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            animateButton = false
                        }
                    }) {
                        Text("Calculate")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(animateButton ? Color.green.opacity(0.6) : Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .scaleEffect(animateButton ? 0.96 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: animateButton)
                    }
                    // В CalculatorMacrosView добавить:
                    if let result = result {
                        MacrosPieChart(
                            protein: Double(result.protein),
                            fat: Double(result.fat),
                            carbs: Double(result.carbs)
                        )
                        .padding(.top, 12)
                    }
                    
                    // Result Card
                    if showResult, let result = result {
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                let formatted = "protein=\(result.protein);fat=\(result.fat);carbs=\(result.carbs)"
                                let historyEntry = CalculationHistory(title: "Macros", result: formatted)
                                historyEntry.macros = MacrosData(
                                    protein: Double(result.protein),
                                    fat: Double(result.fat),
                                    carbs: Double(result.carbs)
                                )
                                onSave("Macros", formatted)
                                dismiss()
                            }) {
                                Text("Save Result")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.top, 12)
                                    .scaleEffect(animateButton ? 0.96 : 1.0)
                            }
                        }
                        
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer()
                }
                .padding()
                
                // Explanation block
                VStack(alignment: .leading, spacing: 8) {
                    Text("How we calculate macros?")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ZStack(alignment: .bottom) {
                        Text("""
    Macronutrients are calculated based on your daily caloric needs and fitness goals. We distribute calories typically as follows:
    
    • Protein: 30% of total calories  
    • Fats: 25%  
    • Carbohydrates: 45%
    
    Each gram of:  
    • Protein = 4 kcal  
    • Carbs = 4 kcal  
    • Fats = 9 kcal
    
    These ratios may vary depending on activity level and body composition goals.
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
                .padding(.horizontal) // Отступы для всех элементов по горизонтали
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
            .background(Color.black.ignoresSafeArea())
        }
    }
        

    private func calculate() {
        guard let total = Int(calories), total > 0 else {
            result = nil
            showResult = false
            return
        }

        let model = MacroCalculatorModel(totalCalories: total, goal: goal)
        result = model.calculateMacros()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CalculatorMacrosView(calculatorType: "Macros") { title, result in
            print("\(title): \(result)")
        }
    }
    .preferredColorScheme(.dark)
}

