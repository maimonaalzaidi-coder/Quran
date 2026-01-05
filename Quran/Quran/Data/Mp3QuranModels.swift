//
//  Quran
//
//  Created by Maimona Alzaidi on 09/06/1447 AH.
//  Models used to decode Quran API responses.
//

import Foundation

// MARK: - Languages
struct LanguagesResponse: Codable {
    let language: [Mp3Language]
}

struct Mp3Language: Codable, Identifiable, Hashable {
    let id: String
    let language: String
    let native: String
    let surah: String
    let reciters: String
}

// MARK: - Suwar
struct SuwarResponse: Codable {
    let suwar: [Surah]
}

struct Surah: Codable, Identifiable, Hashable {
    private let rawId: FlexibleInt
    let name: String

    var id: Int { rawId.value }

    enum CodingKeys: String, CodingKey {
        case rawId = "id"
        case name
    }
}

// MARK: - Reciters
struct RecitersResponse: Codable {
    let reciters: [Reciter]
}

struct Reciter: Codable, Identifiable, Hashable {
    private let rawId: FlexibleInt
    let name: String
    let moshaf: [Moshaf]

    var id: Int { rawId.value }

    enum CodingKeys: String, CodingKey {
        case rawId = "id"
        case name
        case moshaf
    }
}

struct Moshaf: Codable, Identifiable, Hashable {
    private let rawId: FlexibleInt
    let name: String
    let server: String
    let surah_list: String

    var id: Int { rawId.value }

    enum CodingKeys: String, CodingKey {
        case rawId = "id"
        case name
        case server
        case surah_list
    }

    var surahIds: [Int] {
        surah_list
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .sorted()
    }
}
