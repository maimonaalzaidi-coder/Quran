//
//  Quran
//
//  Created by Maimona Alzaidi on 10/06/1447 AH.
//  Service layer for Mp3Quran API requests.
//

import Foundation

final class Mp3QuranService {
    func fetchLanguages() async throws -> [Mp3Language] {
        let res: LanguagesResponse = try await get("https://mp3quran.net/api/v3/languages")
        return res.language
    }

    func fetchSuwar(surahUrl: String) async throws -> [Surah] {
        let res: SuwarResponse = try await get(surahUrl)
        return res.suwar
    }

    func fetchReciters(recitersUrl: String) async throws -> [Reciter] {
        let res: RecitersResponse = try await get(recitersUrl)
        return res.reciters
    }

    func fetchReciterDetails(recitersUrl: String, reciterId: Int) async throws -> Reciter {
        let url = recitersUrl.contains("?")
        ? "\(recitersUrl)&reciter=\(reciterId)"
        : "\(recitersUrl)?reciter=\(reciterId)"

        let res: RecitersResponse = try await get(url)
        guard let first = res.reciters.first else { throw URLError(.cannotParseResponse) }
        return first
    }

    private func get<T: Decodable>(_ urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
