//
//  Kids_motivationApp.swift
//  Kids_motivation
//
//  Created by Anatoly Kuznetsov on 4/12/25.
//

import SwiftUI

struct ProfileView: View {
    let profile: Profile
    @State private var goals: [Goal] = []
    @State private var isLoading = true
    @State private var selectedTask: String = "All tasks"
    @State private var taskFilters: [String] = []
    @State private var strategyMapID = UUID()

    private let allTasksLabel = "All tasks"

    var filteredGoals: [Goal] {
        selectedTask == allTasksLabel ? goals : goals.filter { $0.task == selectedTask }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background image
            Image(backgroundImageName(for: profile.displayName))
                .resizable()
                .saturation(0.8)
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                if isLoading {
                    ProgressView("Loading goals...")
                        .padding(.top, 16)
                } else {
                    StrategyMapView(goals: filteredGoals)
                        .padding(.top, 50) // add space below toolbar
                        .id(strategyMapID)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        // Avatar + title
                        HStack(spacing: 8) {
                            Image(profile.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())

                            Text("Challenges for \(profile.displayName)")
                                .font(.headline)
                                .foregroundColor(.black)
                        }

                        // Filter bar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach([allTasksLabel] + taskFilters, id: \.self) { task in
                                    Text(task)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(selectedTask == task ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            withAnimation {
                                                selectedTask = task
                                                strategyMapID = UUID()
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 9)
                            
                        }
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .overlay(Divider(), alignment: .bottom)
                }
            }
        }
            
        .onAppear(perform: loadCSV)
    }

    private func loadCSV() {
        URLSession.shared.dataTask(with: profile.sheetURL) { data, _, _ in
            guard let data = data,
                  let csv = String(data: data, encoding: .utf8) else { return }

            let parsed = parseCSV(csv: csv)

            DispatchQueue.main.async {
                self.goals = parsed
                self.isLoading = false
                let allTasks = Set(parsed.map { $0.task }.filter { !$0.isEmpty })
                self.taskFilters = Array(allTasks).sorted()
            }
        }.resume()
    }

    private func backgroundImageName(for name: String) -> String {
        switch name {
        case "Maksim": return "pockemon_background"
        case "Rita": return "background_girl"
        default: return "background_default"
        }
    }
}
