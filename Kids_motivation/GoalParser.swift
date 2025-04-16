import Foundation
import TabularData

enum GoalStatus: String, Codable {
    case locked
    case active
    case completed
}

struct Goal: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let task: String
    let category: String
    let level: Int
    let prize: String
    let dependency: [Int]
    let description: String
    var status: GoalStatus
    var lockedBy: [String]? = nil
}

func parseCSV(csv dataFrame: DataFrame) -> [Goal] {
    var rawGoals: [Goal] = []

    for row in dataFrame.rows {
        guard
            let id = row["id"] as? Int,
            let name = row["name"] as? String,
            let task = row["task"] as? String,
            let category = row["category"] as? String,
            let level = row["level"] as? Int,
            let prize = row["prize"] as? String,
            let description = row["description"] as? String
        else {
            continue
        }

        var dependencyIDs: [Int] = []
        if let depString = row["dependency"] as? String {
            dependencyIDs = depString
                .split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        } else if let singleDep = row["dependency"] as? Int {
            dependencyIDs = [singleDep]
        }

        let rawStatus = (row["status"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let initialStatus: GoalStatus = (rawStatus.lowercased() == "done") ? .completed : .locked

        let goal = Goal(
            id: id,
            name: name,
            task: task,
            category: category,
            level: level,
            prize: prize,
            dependency: dependencyIDs,
            description: description,
            status: initialStatus
        )

        rawGoals.append(goal)
    }

    let goalMap = Dictionary(uniqueKeysWithValues: rawGoals.map { ($0.id, $0) })
    var finalGoals: [Goal] = []

    for var goal in rawGoals {
        if goal.status != .completed {
            let unmetDependencies = goal.dependency.filter { goalMap[$0]?.status != .completed }
            if unmetDependencies.isEmpty {
                goal.status = .active
            } else {
                goal.status = .locked
                goal.lockedBy = unmetDependencies.compactMap { goalMap[$0]?.name }
            }
        }
        finalGoals.append(goal)
    }

    // ---- Dependency Graph Printing ----
    let levels = Dictionary(grouping: finalGoals, by: \.level)
    let maxLevel = levels.keys.max() ?? 0
    let sortedLevels = (0...maxLevel).compactMap { levels[$0]?.sorted(by: { $0.id < $1.id }) }

    let dependencyMap = Dictionary(uniqueKeysWithValues: finalGoals.map { ($0.id, $0.dependency) })

    print("🎯 Goal Dependency Layout:")
    for (i, levelGoals) in sortedLevels.enumerated() {
        let row = levelGoals.map { "[\($0.id)]" }.joined(separator: "   ")
        print(row)

        if i < sortedLevels.count - 1 {
            let nextLevelGoals = sortedLevels[i + 1]
            let arrows = levelGoals.map { goal in
                let hasDependent = nextLevelGoals.contains { $0.dependency.contains(goal.id) }
                return hasDependent ? "  |  " : "     "
            }.joined()
            print(arrows)
        }
    }

    return finalGoals
}


