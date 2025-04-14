//
//  Kids_motivationApp.swift
//  Kids_motivation
//
//  Created by Anatoly Kuznetsov on 4/12/25.
//

import SwiftUI
import TabularData

struct ProfileView: View {
    let profile: Profile
    @State private var goals: [Goal] = []
    @State private var isLoading = true
    @State private var selectedTask: String = "All tasks"
    @State private var taskFilters: [String] = []
    @State private var strategyMapID = UUID()
    @State private var topBarHeight: CGFloat = 0
    
    private let allTasksLabel = "All tasks"
    
    var filteredGoals: [Goal] {
        selectedTask == allTasksLabel ? goals : goals.filter { $0.task == selectedTask }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarView(
                profile: profile,
                allTasksLabel: allTasksLabel,
                taskFilters: taskFilters,
                selectedTask: selectedTask,
                onTaskSelect: { task in
                    withAnimation {
                        selectedTask = task
                        strategyMapID = UUID()
                    }
                },
                onHeightChange: { height in
                    topBarHeight = height
                }
            )
            .padding(.top, -45)

            if isLoading {
                ProgressView("Loading goals...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                StrategyMapView(goals: filteredGoals)
                    .id(strategyMapID)
                    .transition(.opacity)
                    .padding(.top, 0) // we no longer need to compensate for top bar height
            }
        }
        .background(
            Image(backgroundImageName(for: profile.displayName))
                .resizable()
                .saturation(0)
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadCSV)
    }
    
    private func loadCSV() {
        Task {
            do {
                let options = CSVReadingOptions(
                    hasHeaderRow: true,
                    nilEncodings: ["", "nil"],
                    ignoresEmptyLines: true
                )
                
                let dataFrame = try DataFrame(contentsOfCSVFile: profile.sheetURL, options: options)
                
                let parsedGoals = parseCSV(csv: dataFrame)
                
                DispatchQueue.main.async {
                    self.goals = parsedGoals
                    self.isLoading = false
                    let allTasks = Set(parsedGoals.map { $0.task }.filter { !$0.isEmpty })
                    self.taskFilters = Array(allTasks).sorted()
                }
                
            } catch {
                print("CSV loading or parsing failed: \(error)")
            }
        }
    }
}
