import SwiftUI

struct GoalInfoView: View {
    let goal: Goal
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(goal.name)
                        .font(.title)
                        .bold()

                    Text("🧠 Category: \(goal.category)")
                    Text("🎁 Prize: \(goal.prize)")
                    Text("🗂 Level: \(goal.level)")
                    Text("🔐 Status: \(goal.status.rawValue.capitalized)")

                    // ✅ Show lockedBy details if applicable
                    if let blockers = goal.lockedBy, !blockers.isEmpty {
                        Text("🚫 Locked by:")
                            .font(.headline)
                            .padding(.top, 10)

                        ForEach(blockers, id: \.self) { blocker in
                            Text("• \(blocker)")
                                .font(.subheadline)
                                .bold()
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("📝 Description")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(extractTextAndLinks(from: goal.description).enumerated()), id: \.offset) { _, view in
                                view
                            }
                        }
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .onAppear {
                    print("📝 Description text: \(goal.description)")
                }
            }
            .navigationTitle("Goal Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Close") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

func extractTextAndLinks(from text: String) -> [AnyView] {
    var result: [AnyView] = []
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    var currentIndex = text.startIndex

    detector?.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
        guard let match = match, let range = Range(match.range, in: text), let url = match.url else { return }

        // Add plain text before link
        if currentIndex < range.lowerBound {
            let plainText = String(text[currentIndex..<range.lowerBound])
            result.append(AnyView(Text(plainText)))
        }

        // Add link as tappable view
        let linkText = String(text[range])
        result.append(AnyView(Link(linkText, destination: url)))

        currentIndex = range.upperBound
    }

    // Add remaining text
    if currentIndex < text.endIndex {
        result.append(AnyView(Text(String(text[currentIndex...]))))
    }

    return result
}
