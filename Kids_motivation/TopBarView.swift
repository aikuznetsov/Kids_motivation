//
//  TopBarView.swift
//  Kids_motivation
//
//  Created by Anatoly Kuznetsov on 4/13/25.
//

import SwiftUI

struct TopBarView: View {
    let profile: Profile
    let allTasksLabel: String
    let taskFilters: [String]
    let selectedTask: String
    let onTaskSelect: (String) -> Void
    let onHeightChange: (CGFloat) -> Void

    var body: some View {
        VStack() {
            HStack(spacing: 8) {
                Image(profile.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                Text("Challenges for \(profile.displayName)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    let local = geo.frame(in: .local)
                                    let global = geo.frame(in: .global)
                                    print("""
                                    🧭 TEXT for \(profile.displayName):
                                    ⤷ Local origin: (\(local.origin.x), \(local.origin.y))
                                    ⤷ Local size: \(local.size.width)x\(local.size.height)
                                    ⤷ Global origin: (\(global.origin.x), \(global.origin.y))
                                    ⤷ Global size: \(global.size.width)x\(global.size.height)
                                    """)
                                }
                        }
                    )
            }
            .padding(.top, 0)
            .frame(maxWidth: .infinity)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([allTasksLabel] + taskFilters, id: \.self) { task in
                        Text(task)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(selectedTask == task ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .onTapGesture {
                                onTaskSelect(task)
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        onHeightChange(geo.size.height)
                    }
            }
        )
        .overlay(Divider(), alignment: .bottom)
    }
}

