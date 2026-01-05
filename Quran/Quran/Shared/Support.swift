//
//     Quran
//
//  Created by maimona alzaidi on 10/06/1447 AH.
//


import SwiftUI

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(String)
}

enum ThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Decodes either Int or String(Int) safely (API fields sometimes vary).
struct FlexibleInt: Codable, Hashable {
    let value: Int

    init(_ value: Int) { self.value = value }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if let i = try? c.decode(Int.self) {
            value = i
            return
        }

        if let s = try? c.decode(String.self),
           let i = Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) {
            value = i
            return
        }

        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Expected Int or String(Int)")
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value)
    }
}
