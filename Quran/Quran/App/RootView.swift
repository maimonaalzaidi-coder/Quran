
//
//  RootView.swift
//  Quran
//
//  Created by Maimona Alzaidi on 07/06/1447 AH.
//  Manages splash screen and app initialization.
//

import SwiftUI
import Combine
struct RootView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @State private var showMain = false

    var body: some View {
        Group {
            if showMain {
                MainView()
            } else {
                SplashView()
            }
        }
        .task {
            do {
                try await appVM.bootstrap()
            } catch {
                // Continue anyway; MainView has retry UI
            }

            try? await Task.sleep(nanoseconds: 900_000_000) // splash delay
            showMain = true
        }
    }
}

@MainActor
final class AppViewModel: ObservableObject {
    @AppStorage("themeMode") private var themeModeRaw: String = ThemeMode.system.rawValue

    @Published var languages: [Mp3Language] = []
    @Published var selectedLanguage: Mp3Language? = nil

    private let service = Mp3QuranService()

    var themeMode: ThemeMode {
        get { ThemeMode(rawValue: themeModeRaw) ?? .system }
        set { themeModeRaw = newValue.rawValue }
    }

    func bootstrap() async throws {
        let langs = try await service.fetchLanguages()
        languages = langs

        if selectedLanguage == nil {
            selectedLanguage = langs.first(where: { $0.native.contains("العربية") }) ?? langs.first
        }
    }
}
