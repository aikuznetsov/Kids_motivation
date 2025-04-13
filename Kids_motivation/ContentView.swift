//  ContentView.swift
//  Kids_motivation
//
//  Created by Anatoly Kuznetsov on 4/12/25.
//

import SwiftUI

enum Profile: Hashable {
    case profileA
    case profileB

    var sheetURL: URL {
        switch self {
        case .profileA:
            return URL(string: "https://docs.google.com/spreadsheets/d/1GrSbBUicZOiOBbG6iJ7fmFq8ckYHXMUgcY2jpiG9I14/export?format=csv")!
        case .profileB:
            return URL(string: "https://docs.google.com/spreadsheets/d/<SHEET_ID_2>/export?format=csv")!
        }
    }

    var displayName: String {
        switch self {
        case .profileA: return "Maksim"
        case .profileB: return "Rita"
        }
    }

    var imageName: String {
        switch self {
        case .profileA: return "boy"
        case .profileB: return "girl"
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Choose a Profile")
                    .font(.title)
                    .bold()
                    .padding(.top, 40)

                Spacer()

                VStack(spacing: 40) {
                    NavigationLink(value: Profile.profileA) {
                        VStack {
                            Image("boy")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 5)

                            Text("Maksim")
                                .bold()
                                .font(.title)
                        }
                    }

                    NavigationLink(value: Profile.profileB) {
                        VStack {
                            Image("girl")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 5)

                            Text("Rita")
                                .bold()
                                .font(.title)
                        }
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationDestination(for: Profile.self) { profile in
                ProfileView(profile: profile)
            }
        }
    }
}
