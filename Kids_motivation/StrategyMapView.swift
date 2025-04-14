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
                                                    
                                                    if allPositionsReady {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                            canvasRefreshTrigger += 1

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
                        // Precompute all incoming dependencies per goal
                        let goalToIncomingDeps: [Int: [Int]] = goals.reduce(into: [:]) { result, goal in
                            for depID in goal.dependency {
                                result[goal.id, default: []].append(depID)
                            }
                        }

                        for goal in goals {
                            guard let toBase = positions[goal.id] else { continue }
                            let incoming = goalToIncomingDeps[goal.id] ?? []

                            // Sort dependencies by x position of their start points
                            let sortedIncoming = incoming.sorted {
                                guard let p1 = positions[$0], let p2 = positions[$1] else { return false }
                                return p1.x < p2.x
                            }

                            for (index, depID) in sortedIncoming.enumerated() {
                                guard let from = positions[depID] else { continue }

                                // Offset only the end point to spread arrows
                                let spacing: CGFloat = 20
                                let spread = CGFloat(sortedIncoming.count - 1) / 2.0
                                let offset = CGFloat(index) - spread
                                let to = CGPoint(x: toBase.x + offset * spacing, y: toBase.y)

                                print("🟥 Drawing arrow from \(depID) to \(goal.id)")
                                print("   ↳ From: \(from), To: \(to), Offset: \(offset * spacing)")

                                drawArrow(from: from, to: to, in: context)
                            }
                        }
                    }
                    .id(canvasRefreshTrigger)
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
