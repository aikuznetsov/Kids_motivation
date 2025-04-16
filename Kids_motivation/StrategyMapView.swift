import SwiftUI

struct StrategyMapView: View {
    let goals: [Goal]

    @State private var positions: [Int: CGPoint] = [:]
    @State private var placedGoals: Set<Int> = []
    @State private var selectedGoal: Goal?
    @State private var canvasRefreshTrigger = 0
    @State private var contentWidth: CGFloat = 100
    @State private var contentHeight: CGFloat = 100

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {
                ForEach(placedGoals.sorted(), id: \.self) { goalID in
                    if let goal = goalByID[goalID], let position = positions[goalID] {
                        Button {
                            selectedGoal = goal
                        } label: {
                            GoalCard(goal: goal)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 130, height: 100)
                        .position(position)
                    }
                }

                if allPositionsReady {
                    Canvas { context, _ in
                        // Step 1: Collect incoming dependencies per goal
                        var incomingOffsets: [Int: [Int]] = [:]
                        for goal in goals {
                            for depID in goal.dependency {
                                incomingOffsets[goal.id, default: []].append(depID)
                            }
                        }

                        // Step 2: Draw arrows with offsets to prevent overlap
                        for goal in goals {
                            guard let toBase = positions[goal.id] else { continue }
                            let incoming = incomingOffsets[goal.id] ?? []

                            for depID in goal.dependency {
                                guard let from = positions[depID] else { continue }

                                // Sort dependencies based on horizontal x position
                                let sortedDeps = incoming.sorted {
                                    (positions[$0]?.x ?? 0) < (positions[$1]?.x ?? 0)
                                }

                                guard let depOrderIndex = sortedDeps.firstIndex(of: depID) else { continue }

                                let spacing: CGFloat = 20
                                let spread = CGFloat(sortedDeps.count - 1) / 2.0
                                let offset = CGFloat(depOrderIndex) - spread

                                let to = CGPoint(x: toBase.x + offset * spacing, y: toBase.y)
                                drawArrow(from: from, to: to, in: context)
                            }
                        }
                    }
                    .id(canvasRefreshTrigger)
                    .allowsHitTesting(false)
                }

            }
            .frame(width: contentWidth, height: contentHeight)
            .background(Color.clear)
        }
        .padding(40)
        .coordinateSpace(name: "scroll")
        .sheet(item: $selectedGoal) { goal in
            GoalInfoView(goal: goal)
        }
        .onAppear {
            placeGoalsProgressively()
        }
    }


    private var goalByID: [Int: Goal] {
        Dictionary(uniqueKeysWithValues: goals.map { ($0.id, $0) })
    }

    private var allPositionsReady: Bool {
        positions.count == goals.count
    }

    private func placeGoalsProgressively() {
        let cardSize = CGSize(width: 130, height: 100)
        let horizontalSpacing: CGFloat = 60
        let verticalSpacing: CGFloat = 100
        let groupSpacing: CGFloat = 10
        let paddingX: CGFloat = 200
        let paddingY: CGFloat = 200

        // Step 1: Build dependency graph
        var graph = [Int: Set<Int>]()
        var reverseGraph = [Int: Set<Int>]()
        for goal in goals {
            for dep in goal.dependency {
                graph[dep, default: []].insert(goal.id)
                reverseGraph[goal.id, default: []].insert(dep)
            }
        }

        // Step 2: Find connected components (groups)
        var visited = Set<Int>()
        var groups: [[Goal]] = []

        func dfs(_ id: Int, _ group: inout Set<Int>) {
            guard !visited.contains(id) else { return }
            visited.insert(id)
            group.insert(id)

            for neighbor in graph[id, default: []] {
                dfs(neighbor, &group)
            }
            for neighbor in reverseGraph[id, default: []] {
                dfs(neighbor, &group)
            }
        }

        for goal in goals {
            if !visited.contains(goal.id) {
                var group = Set<Int>()
                dfs(goal.id, &group)
                groups.append(goals.filter { group.contains($0.id) })
            }
        }

        // Step 3: Place each group with offset
        var positionsTemp: [Int: CGPoint] = [:]
        var newPlacedGoals: Set<Int> = []
        var currentGroupOffsetX: CGFloat = 0
        var maxHeightInGroups: CGFloat = 0

        for group in groups {
            let levels = computeLevels(from: group)

            for (levelIndex, levelGoals) in levels.enumerated() {
                let y = CGFloat(levelIndex) * (cardSize.height + verticalSpacing) + paddingY

                for (i, goal) in levelGoals.enumerated() {
                    let x = currentGroupOffsetX + CGFloat(i) * (cardSize.width + horizontalSpacing) + paddingX
                    let point = CGPoint(x: x, y: y)
                    positionsTemp[goal.id] = point
                    newPlacedGoals.insert(goal.id)

                    print("🧩 Grouped: goal \(goal.id) \"\(goal.name)\" at \(point)")
                }

                maxHeightInGroups = max(maxHeightInGroups, y)
            }

            currentGroupOffsetX += CGFloat(levels.map(\.count).max() ?? 1) * (cardSize.width + horizontalSpacing) + groupSpacing
        }

        positions = positionsTemp
        placedGoals = newPlacedGoals

        contentWidth = currentGroupOffsetX + paddingX
        contentHeight = maxHeightInGroups + cardSize.height + paddingY

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            canvasRefreshTrigger += 1
        }
    }

    
    private func computeLevels(from goals: [Goal]) -> [[Goal]] {
        var goalMap = Dictionary(uniqueKeysWithValues: goals.map { ($0.id, $0) })
        var inDegree = Dictionary(uniqueKeysWithValues: goals.map { ($0.id, 0) })

        // Count how many times each goal is depended on (in-degree)
        for goal in goals {
            for dep in goal.dependency {
                inDegree[goal.id, default: 0] += 1
            }
        }

        // Track reverse dependencies: who depends on whom
        var reverseDeps = [Int: Set<Int>]()
        for goal in goals {
            for dep in goal.dependency {
                reverseDeps[dep, default: []].insert(goal.id)
            }
        }

        // Level generation via topological sort (Kahn’s algorithm)
        var levels: [[Goal]] = []
        var queue = goals.filter { inDegree[$0.id] == 0 }

        while !queue.isEmpty {
            levels.append(queue)
            var nextQueue: [Goal] = []

            for goal in queue {
                for g in goals {
                    if g.dependency.contains(goal.id) {
                        inDegree[g.id, default: 0] -= 1
                        if inDegree[g.id] == 0 {
                            nextQueue.append(g)
                        }
                    }
                }
            }

            queue = nextQueue
        }

        // Log reverse dependency map
        print("📌 Reverse dependencies map:")
        for (key, value) in reverseDeps {
            print("  Goal [\(key)] is depended on by: \(value.sorted())")
        }

        // Reorder each level: goals not depended on go left
        for (i, level) in levels.enumerated() {
            print("\n🔢 Sorting level \(i):", level.map { "[\($0.id)]" }.joined(separator: ", "))

            levels[i] = level.sorted { a, b in
                let aDependedOn = reverseDeps[a.id]?.isEmpty == false
                let bDependedOn = reverseDeps[b.id]?.isEmpty == false

                print("↪️ Compare [\(a.id)] (depended: \(aDependedOn)) vs [\(b.id)] (depended: \(bDependedOn))")

                if aDependedOn != bDependedOn {
                    return !aDependedOn // prefer goals not depended on
                }
                return false // preserve original order otherwise
            }

            print("✅ Sorted level \(i):", levels[i].map { "[\($0.id)]" }.joined(separator: ", "))
        }

        // Final pretty-printed layout
        print("\n🎯 Goal Dependency Layout:")
        for (i, levelGoals) in levels.enumerated() {
            let row = levelGoals.map { "[\($0.id)]" }.joined(separator: "   ")
            print(row)

            if i < levels.count - 1 {
                let nextLevelGoals = levels[i + 1]
                let arrows = levelGoals.map { goal in
                    let hasDependent = nextLevelGoals.contains { $0.dependency.contains(goal.id) }
                    return hasDependent ? "  |  " : "     "
                }.joined()
                print(arrows)
            }
        }

        return levels
    }


}



private extension Array where Element == CGFloat {
    var average: CGFloat? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / CGFloat(count)
    }
}
