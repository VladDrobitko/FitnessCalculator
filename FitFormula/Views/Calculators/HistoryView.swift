//
//  HistoryView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 05/04/2025.
//
import SwiftUI
import SwiftData

struct HistoryView: View {
    let history: [CalculationHistory]
    let deleteItem: (CalculationHistory) -> Void
    
    // Состояния для фильтрации и сортировки
    @State private var selectedFilterIndex = 0
    @State private var sortNewestFirst = true
    
    // Определение типов фильтров
    private let filterOptions: [(title: String, filter: ((CalculationHistory) -> Bool))] = [
        ("All Types", { _ in true }),
        ("Calories", { $0.title == "Calories" }),
        ("Macros", { $0.title == "Macros" }),
        ("BMI", { $0.title == "BMI" }),
        ("Water Intake", { $0.title == "Water Intake" })
    ]
    
    // Отфильтрованные записи
    private var filteredHistory: [CalculationHistory] {
        return history.filter(filterOptions[selectedFilterIndex].filter)
    }
    
    // Отсортированные записи (на основе отфильтрованных)
    private var sortedHistory: [CalculationHistory] {
        return filteredHistory.sorted { first, second in
            if sortNewestFirst {
                return first.date > second.date
            } else {
                return first.date < second.date
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Заголовок с количеством записей
            HStack {
                Text("Calculation History")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Количество отображаемых записей / всего записей
                let filteredCount = filteredHistory.count
                let totalCount = history.count
                Text("\(filteredCount)/\(totalCount)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // Секция фильтров и сортировки
            VStack(spacing: 12) {
                // Пикер для фильтра
                HStack {
                    Picker("", selection: $selectedFilterIndex) {
                        ForEach(0..<filterOptions.count, id: \.self) { index in
                            Text(filterOptions[index].title)
                                .tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    .labelsHidden()
                    .padding(.leading, 9)// Убираем скрытую метку "Filter", которая может влиять на выравнивание
                    
                    Spacer()
                    
                    // Простая кнопка сортировки
                    Button(action: {
                        sortNewestFirst.toggle()
                    }) {
                        Image(systemName: sortNewestFirst ? "arrow.down" : "arrow.up")
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
            }
            
            
            // Список истории
            if sortedHistory.isEmpty {
                EmptyHistoryView(
                    filterTitle: filterOptions[selectedFilterIndex].title,
                    isFiltered: selectedFilterIndex != 0,
                    resetFilter: { selectedFilterIndex = 0 }
                )
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HistoryListView(
                    entries: sortedHistory,
                    getIcon: getIcon,
                    formatResult: formatResult,
                    deleteItem: deleteItem
                )
                .listStyle(.inset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(12)
        .padding(.trailing)
    }

    // Получение иконки для типа калькулятора
    func getIcon(for title: String) -> String {
        switch title {
        case "Calories": return "flame.fill"
        case "Macros": return "chart.pie.fill"
        case "Water Intake": return "drop.fill"
        case "BMI": return "figure.stand"
        default: return "questionmark.circle"
        }
    }
    
    // Получение иконки для опции фильтра
    func getIconForFilterOption(_ index: Int) -> String {
        let title = filterOptions[index].title
        if title == "All Types" {
            return "square.grid.2x2"
        } else {
            return getIcon(for: title)
        }
    }
    
    // Форматирование результата для читабельного отображения
    func formatResult(_ title: String, _ result: String) -> String {
        // Парсинг ключ-значений
        let dict = parseResult(result)
        
        switch title {
        case "Calories":
            if let tdeeStr = dict["tdee"], let goalCalStr = dict["goalCalories"],
               let tdee = Double(tdeeStr), let goalCal = Double(goalCalStr) {
                return "\(Int(tdee)) kcal → \(Int(goalCal)) kcal"
            }
            
        case "BMI":
            if let bmiStr = dict["bmi"], let bmi = Double(bmiStr) {
                let category = getBMICategory(bmi)
                return "\(String(format: "%.1f", bmi)) - \(category)"
            }
            
        case "Water Intake":
            if let waterStr = dict["result"], let water = Double(waterStr) {
                return "\(String(format: "%.1f", water)) L/day"
            }
            
        case "Macros":
            if let proteinStr = dict["protein"], let fatStr = dict["fat"], let carbsStr = dict["carbs"],
               let protein = Double(proteinStr), let fat = Double(fatStr), let carbs = Double(carbsStr) {
                return "P: \(Int(protein))g, F: \(Int(fat))g, C: \(Int(carbs))g"
            }
        default:
            break
        }
        
        // Если ничего не сработало, вернуть исходную строку
        return result
    }
    
    // Парсинг результата
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
    
    // Получение категории BMI
    private func getBMICategory(_ bmi: Double) -> String {
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
}

// Пустое состояние истории
struct EmptyHistoryView: View {
    let filterTitle: String
    let isFiltered: Bool
    let resetFilter: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No results found")
                .font(.headline)
                .foregroundColor(.white)
            
            let messageText = !isFiltered ?
                "Your calculation history is empty" :
                "No \(filterTitle) calculations found"
            
            Text(messageText)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if isFiltered {
                Button(action: resetFilter) {
                    Text("Show all calculations")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            }
        }
    }
}

// Список истории
struct HistoryListView: View {
    let entries: [CalculationHistory]
    let getIcon: (String) -> String
    let formatResult: (String, String) -> String
    let deleteItem: (CalculationHistory) -> Void
    
    var body: some View {
        List {
            ForEach(entries) { entry in
                NavigationLink(destination: CalculationDetailView(entry: entry)) {
                    HistoryItemView(
                        entry: entry,
                        getIcon: getIcon,
                        formatResult: formatResult
                    )
                }
                .listRowBackground(Color.clear)
                .swipeActions {
                    Button(role: .destructive) {
                        deleteItem(entry)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

// Элемент истории
struct HistoryItemView: View {
    let entry: CalculationHistory
    let getIcon: (String) -> String
    let formatResult: (String, String) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Image(systemName: getIcon(entry.title))
                    .foregroundColor(.green)
                    .font(.system(size: 16))
            }
            Text(formatResult(entry.title, entry.result))
                .foregroundColor(.gray)
            Text(entry.date, style: .date)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        .padding(.leading, 0)
    }
}

// Предпросмотр
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            HistoryView(history: [
                CalculationHistory(title: "Calories", result: "tdee=2500;goalCalories=2200;goal=maintain"),
                CalculationHistory(title: "BMI", result: "bmi=24.5"),
                CalculationHistory(title: "Water Intake", result: "result=2.5"),
                CalculationHistory(title: "Macros", result: "protein=150;fat=70;carbs=250")
            ], deleteItem: { _ in })
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}

