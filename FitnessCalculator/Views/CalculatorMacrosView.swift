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
    
    // Info block
    @State private var showFullInfo = false


    @State private var calories: String = ""
    @State private var goal: MacroGoal = .maintain
    @State private var result: MacroResult?
    @State private var showResult = false
    @State private var animateButton = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Macro Calculator")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                // Input
                HStack {
                    Text("Calories:")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("kcal", text: $calories)
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

                // Result Card
                if showResult, let result = result {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Result for \(result.description):")
                            .font(.headline)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 4) {
                            Label("Protein: \(result.protein)g", systemImage: "flame.fill")
                            Label("Fat: \(result.fat)g", systemImage: "drop.fill")
                            Label("Carbs: \(result.carbs)g", systemImage: "leaf.fill")
                        }
                        .foregroundColor(.green)

                        Button(action: {
                            let formatted = "protein=\(result.protein);fat=\(result.fat);carbs=\(result.carbs)"
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
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
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
        
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
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

