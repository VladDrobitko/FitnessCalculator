//
//  CalculatorInputView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 04/04/2025.
//
import SwiftUI

struct CalculatorCaloriesView: View {
    let calculatorType: String
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    
    @State private var isPressed = false
    @State private var isSavePressed = false

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
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                // Weight
                HStack {
                    Text("Weight (kg):")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("kg", text: $weight)
                        .keyboardType(.decimalPad)
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

                

                

                // ... весь остальной код без изменений ...

                // Заменяем блок result + save button:
                if !resultText.isEmpty {
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
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isSavePressed = true
                            }
                            let formattedResult = "tdee=\(tdee);goalCalories=\(goalCalories);goal=\(goal.rawValue)"
                            onSave("Calories", formattedResult)
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
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }

    private func calculate() {
        guard let age = Int(age),
              let height = Double(height),
              let weight = Double(weight) else {
            resultText = "Please enter valid data."
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

