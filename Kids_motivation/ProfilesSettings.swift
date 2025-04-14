//
//  profiles_settings.swift
//  Kids_motivation
//
//  Created by Anatoly Kuznetsov on 4/13/25.
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
            return URL(string: "https://docs.google.com/spreadsheets/d/1inHONICcEXK8-OB0R4tzHWqGF7eIeSFjubN8Oyg8qcg/export?format=csv")!
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

func backgroundImageName(for name: String) -> String {
    switch name {
    case "Maksim": return "pockemon_background"
    case "Rita": return "cinnamoroll"
    default: return "background_default"
    }
}
