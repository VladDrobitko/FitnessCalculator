//
//  BMICalculatorView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//

import SwiftUI

struct BMICalculatorView: View {
    let calculatorType: String
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss

    // Inputs
    @State private var weight: String = ""
    @State private var height: String = ""
    
    // Result
    @State private var bmiResult: Double = 0
    @State private var bmiCategory: String = ""
    
    // Info block
    @State private var showFullInfo = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("BMI Calculator")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // Weight input
                HStack {
                    Text("Weight (kg):")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("kg", text: $weight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                
                // Height input
                HStack {
                    Text("Height (cm):")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("cm", text: $height)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
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
                
                // Result
                if bmiResult > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BMI Result:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("BMI: \(String(format: "%.2f", bmiResult))")
                            .foregroundColor(.green)
                        Text("Category: \(bmiCategory)")
                            .foregroundColor(.green)
                    }
                    .padding(.top, 12)
                    
                    // В BMICalculatorView добавить:
                    if bmiResult > 0 {
                        BMIScaleView(bmi: bmiResult)
                            .padding(.top, 12)
                    }
                }
                
                // Save button
                if bmiResult > 0 {
                    Button(action: {
                        onSave("BMI", "bmi=\(bmiResult)")
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
                    Text("How we calculate BMI?")
                        .font(.headline)
                        .foregroundColor(.white)
                        //.padding(.horizontal)
                    
                    ZStack(alignment: .bottom) {
                        Text("""
BMI is calculated based on your weight and height using the following formula: BMI is determined by dividing your weight in kilograms by the square of your height in meters, which gives you the BMI value that can be categorized into different ranges based on health risk factors.

• BMI = weight (kg) / height² (m)

Based on the result, the categories are:

• Underweight: BMI < 18.5
• Normal weight: 18.5 ≤ BMI ≤ 24.9
• Overweight: 25 ≤ BMI ≤ 29.9
• Obesity: BMI ≥ 30
""")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        //.padding(.horizontal)
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
                    //.padding(.horizontal)
                }
                //.padding(.horizontal)
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
        guard let weight = Double(weight), let height = Double(height) else {
            bmiResult = 0
            bmiCategory = "Please enter valid data."
            return
        }

        // Convert height to meters
        let heightInMeters = height / 100

        let model = BMICalculatorModel(weight: weight, height: heightInMeters)
        bmiResult = model.calculateBMI()
        bmiCategory = model.getBMICategory()
    }
}

struct BMICalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            BMICalculatorView(calculatorType: "BMI") { title, result in
                print("Result for \(title): \(result)")
            }
        }
        .preferredColorScheme(.dark)
    }
}

