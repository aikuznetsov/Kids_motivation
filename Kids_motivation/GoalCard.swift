import SwiftUI

struct GoalCard: View {
    let goal: Goal

    var body: some View {
        let isLocked = goal.status == .locked
        let isCompleted = goal.status == .completed

        ZStack {
            VStack(spacing: 8) {
                categoryIcon(for: goal.category)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .saturation(isLocked ? 0 : 1)

                Text(goal.name)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(backgroundColor(for: goal.status))
                    .cornerRadius(8)

                Text(goal.prize)
                    .font(isLocked ? .caption : .headline)
                    .foregroundColor(isLocked ? .secondary : .primary)
                    .bold()
            }
            .frame(width: 130, height: 160) // increased height
            .background(isLocked ? Color.gray.opacity(0.2) : Color.white)
            .padding(4)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 3)
            .contentShape(Rectangle())

            if isCompleted {
                Text("COMPLETED")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)
                    .rotationEffect(.degrees(-30))
                    .offset(y: -30)
            }
        }
    }

    func backgroundColor(for status: GoalStatus) -> Color {
        switch status {
        case .completed: return Color.green.opacity(0.5)
        case .active: return Color.blue.opacity(0.4)
        case .locked: return Color.gray.opacity(0.2)
        }
    }

    func categoryIcon(for category: String) -> Image {
        let normalized = category
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")

        if UIImage(named: normalized) != nil {
            return Image(normalized)
        } else {
            return Image(systemName: "questionmark.circle")
        }
    }
}
