//
//  GoalParser.swift
//  Kids_motivation
//
//  Created by Anatoly Kuznetsov on 4/12/25.
//

import Foundation

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
    var lockedBy: [String]? = nil  // ✅ New field
}

func parseCSV(csv: String) -> [Goal] {
    let lines = csv.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    let dataLines = lines.dropFirst()

    var rawGoals: [Goal] = []

    for line in dataLines {
        let columns = line.components(separatedBy: ",")
        if columns.count >= 8 {
            let id = Int(columns[0].trimmingCharacters(in: .whitespaces)) ?? 0
            let name = columns[1]
            let task = columns[2]
            let category = columns[3]
            let level = Int(columns[4]) ?? 1
            let prize = columns[5]
            let dependenciesString = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
            let dependencyIDs = dependenciesString
                .split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let description = columns[7]
            let rawStatus = columns.count > 8 ? columns[8].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let initialStatus: GoalStatus = (rawStatus.lowercased() == "done") ? .completed : .locked

            rawGoals.append(Goal(
                id: id,
                name: name,
                task: task,
                category: category,
                level: level,
                prize: prize,
                dependency: dependencyIDs,
                description: description,
                status: initialStatus
            ))
        }
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

    return finalGoals
}
