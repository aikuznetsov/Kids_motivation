import SwiftUI

import SwiftUI

struct StrategyMapView: View {
    let goals: [Goal]

    @State private var positions: [Int: CGPoint] = [:]
    @State private var selectedGoal: Goal?
    @State private var canvasRefreshTrigger = 0

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 100) {
                    ForEach(levels, id: \.self) { level in
                        HStack(spacing: 60) {
                            ForEach(goalsByLevel[level] ?? [], id: \.self) { goal in
                                Button {
                                    selectedGoal = goal
                                } label: {
                                    GoalCard(goal: goal)
                                }
                                .buttonStyle(.plain)
                                .frame(width: 130, height: 100)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onAppear {
                                                DispatchQueue.main.async {
                                                    let center = CGPoint(
                                                        x: geo.frame(in: .named("scroll")).midX,
                                                        y: geo.frame(in: .named("scroll")).midY
                                                    )
                                                    positions[goal.id] = center
                                                    print("📌 Position set for goal \(goal.id): \(center)")
                                                    
                                                    if allPositionsReady {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                            canvasRefreshTrigger += 1
                                                            print("🔁 Triggered canvas redraw")
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                )
                            }
                        }
                    }
                }

                if allPositionsReady {
                    Canvas { context, size in
                        for goal in goals {
                            for depID in goal.dependency {
                                if let from = positions[depID],
                                   let to = positions[goal.id] {
                                    print("🟥 Drawing arrow from \(depID) to \(goal.id)")
                                    drawArrow(from: from, to: to, in: context)
                                }
                            }
                        }
                    }
                    .id(canvasRefreshTrigger) // 🟢 Force redraw when ID changes
                    .allowsHitTesting(false)
                }
            }
            .coordinateSpace(name: "scroll")
            .padding(.top, 30) 
            .onChange(of: goals.map(\.id)) { _ in
                positions = [:] // 🧹 Reset all positions
            }
        }
        .sheet(item: $selectedGoal) { goal in
            GoalInfoView(goal: goal)
                .onAppear {
                    print("🟢 Presenting GoalInfoView for: \(goal.name)")
                }
        }
    }

    var levels: [Int] {
        Set(goals.map { $0.level }).sorted()
    }

    var goalsByLevel: [Int: [Goal]] {
        Dictionary(grouping: goals, by: \.level)
    }

    var allPositionsReady: Bool {
        goals.allSatisfy { positions[$0.id] != nil }
    }
}
