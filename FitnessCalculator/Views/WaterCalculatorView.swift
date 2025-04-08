//
//  WaterCalculatorView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//

import SwiftUI

struct WaterCalculatorView: View {
    let calculatorType: String
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss

    // Inputs
    @State private var weight: String = ""
    @State private var gender: Gender = .male // Добавляем выбор пола
    @State private var activityLevel: ActivityLevel = .sedentary // Используем enum вместо Double
    @State private var climate: ClimateType = .temperate // Добавляем климат

    // Result
    @State private var resultText: String = ""
    @State private var waterIntake: Double = 0

    // Info block
    @State private var showFullInfo = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Water Calculator")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                // Gender selection
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

                // Climate
                HStack() {
                    Text("Climate:")
                        .foregroundColor(.white)
                    Spacer()
                    Picker("Climate", selection: $climate) {
                        ForEach(ClimateType.allCases) { climateType in
                            Text(climateType.description).tag(climateType)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                }

                // Calculate button
                Button(action: calculate) {
                    Text("Calculate")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }

                // Result section
                if !resultText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended Water Intake:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(resultText)
                            .foregroundColor(.green)
                        
                        // Добавляем визуализацию
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { index in
                                Image(systemName: index < Int(waterIntake * 4) ? "drop.fill" : "drop")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.top, 8)
                        
                        Text("≈ \(Int(waterIntake * 1000 / 250)) glasses (250ml) per day")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }

                // Save button
                if !resultText.isEmpty {
                    Button(action: {
                        let formattedResult = "result=\(waterIntake)"
                        let historyEntry = CalculationHistory(title: "Water Intake", result: formattedResult)
                        historyEntry.water = WaterData(dailyIntake: waterIntake)
                        onSave("Water Intake", formattedResult)
                        dismiss()
                    }) {
                        Text("Save Result")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 12)
                    }
                }

                Spacer()

                // Explanation block
                VStack(alignment: .leading, spacing: 8) {
                    Text("How we calculate water intake")
                        .font(.headline)
                        .foregroundColor(.white)
                        
                    ZStack(alignment: .bottom) {
                        Text("""
Water intake is calculated based on your body weight, gender, activity level, and climate:

• Base recommendation: 31-35 ml per kg of body weight (varies by gender)
• Activity level adjustments: +300-1000 ml depending on intensity
• Climate adjustments: Increased intake for hot, humid, or dry environments

Drinking adequate water supports metabolism, exercise performance, and cognitive function. Requirements vary by individual, so adjust based on your personal needs.
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
        guard let weight = Double(weight) else {
            resultText = "Please enter valid weight."
            return
        }

        let model = WaterCalculatorModel(
            weight: weight,
            gender: gender,
            activityLevel: activityLevel,
            climate: climate
        )

        waterIntake = model.calculateWaterIntake()

        resultText = """
        Recommended daily water intake: \(String(format: "%.1f", waterIntake)) liters.
        """
    }
}

struct WaterCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            WaterCalculatorView(calculatorType: "Water") { title, result in
                print("Result for \(title): \(result)")
            }
        }
        .preferredColorScheme(.dark)
    }
}

