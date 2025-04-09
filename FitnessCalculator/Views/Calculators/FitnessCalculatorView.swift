//
//  ContentView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 04/04/2025.
//

import SwiftUI
import SwiftData

struct FitnessCalculatorView: View {
    @State private var selectedCalculator: Calculator? = nil
    @Query private var history: [CalculationHistory]
    @Environment(\.modelContext) private var modelContext

    let calculators = [
        Calculator(title: "Calories", icon: "flame.fill"),
        Calculator(title: "Macros", icon: "chart.pie.fill"),
        Calculator(title: "Water Intake", icon: "drop.fill"),
        Calculator(title: "BMI", icon: "figure.stand")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(calculators) { calculator in
                        Button(action: {
                            selectedCalculator = calculator
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: calculator.icon)
                                    .foregroundColor(.green)
                                    .font(.system(size: 40))
                                    .frame(width: 80, height: 80)

                                Text(calculator.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(
                                VisualEffectBlur()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .frame(height: 0.5)
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal)

                HistoryView(history: history, deleteItem: { item in
                    modelContext.delete(item)
                })

                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .sheet(item: $selectedCalculator) { calculator in
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    switch CalculatorType(title: calculator.title) {
                    case .calories:
                        CalculatorCaloriesView(calculatorType: calculator.title) { title, result in
                            let newEntry = CalculationHistory(title: title, result: result)
                            modelContext.insert(newEntry)
                        }
                        .withDragIndicator()

                    case .macros:
                        CalculatorMacrosView(calculatorType: calculator.title) { title, result in
                            let newEntry = CalculationHistory(title: title, result: result)
                            modelContext.insert(newEntry)
                        }
                        .withDragIndicator()

                    case .water:
                        WaterCalculatorView(calculatorType: calculator.title) { title, result in
                            let newEntry = CalculationHistory(title: title, result: result)
                            modelContext.insert(newEntry)
                        }
                        .withDragIndicator()

                    case .bmi:
                        BMICalculatorView(calculatorType: calculator.title) { title, result in
                            let newEntry = CalculationHistory(title: title, result: result)
                            modelContext.insert(newEntry)
                        }
                        .withDragIndicator()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct FitnessCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessCalculatorView()
            .preferredColorScheme(.dark)
    }
}









