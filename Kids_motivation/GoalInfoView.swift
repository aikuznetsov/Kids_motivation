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

                        Text(goal.description)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
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
