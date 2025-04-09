//
//  MainTabView.swift
//  FitnessCalculator
//
//  Created by Владислав Дробитько on 08/04/2025.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        ZStack {
            TabView {
                
                    FitnessCalculatorView()
                        
                
                .tabItem {
                    Label("Calculators", systemImage: "plus.forwardslash.minus")
                }
                
                
                    StatisticsView()
                        
                
                .tabItem {
                    Label("Statistics", systemImage: "chart.xyaxis.line")
                }
            }
            .accentColor(.green)
            .preferredColorScheme(.dark)
        }
    }
}




