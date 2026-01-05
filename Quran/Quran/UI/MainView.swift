
//     Quran
//
//  Created by maimona alzaidi on 07/06/1447 AH.
//


import SwiftUI
import Combine
struct MainView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var vm = RecitersListVM()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                topControls
                content
            }
            .navigationTitle("Reciters")
            .searchable(text: $vm.searchText, prompt: "Search by name")
            .task {
                if let lang = appVM.selectedLanguage {
                    await vm.load(language: lang)
                }
            }
            .onChange(of: appVM.selectedLanguage) { _, newLang in
                guard let newLang else { return }
                Task { await vm.load(language: newLang) }
            }
        }
    }

    private var topControls: some View {
        VStack(spacing: 10) {
            HStack {
                Picker("Language", selection: $appVM.selectedLanguage) {
                    ForEach(appVM.languages, id: \.self) { lang in
                        Text("\(lang.native) (\(lang.language))")
                            .tag(Optional(lang))
                    }
                }
                .pickerStyle(.menu)

                Spacer()

                Button(vm.sortAscending ? "A→Z" : "Z→A") {
                    vm.sortAscending.toggle()
                }
                .buttonStyle(.bordered)
            }

            Picker("Theme", selection: Binding(
                get: { appVM.themeMode },
                set: { appVM.themeMode = $0 }
            )) {
                ForEach(ThemeMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            VStack(spacing: 10) {
                Text("Failed to load")
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    if let lang = appVM.selectedLanguage {
                        Task { await vm.load(language: lang) }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let reciters):
            List(vm.filteredSorted(reciters)) { reciter in
                NavigationLink(reciter.name) {
                    if let lang = appVM.selectedLanguage {
                        ReciterDetailsView(
                            reciterId: reciter.id,
                            recitersUrl: lang.reciters,
                            suwarById: vm.suwarById
                        )
                    }
                }
            }
        }
    }
}

@MainActor
final class RecitersListVM: ObservableObject {
    @Published var state: ViewState<[Reciter]> = .idle
    @Published var suwarById: [Int: Surah] = [:]

    @Published var searchText: String = ""
    @Published var sortAscending: Bool = true

    private let service = Mp3QuranService()

    func load(language: Mp3Language) async {
        state = .loading
        do {
            let suwar = try await service.fetchSuwar(surahUrl: language.surah)
            suwarById = Dictionary(uniqueKeysWithValues: suwar.map { ($0.id, $0) })

            let reciters = try await service.fetchReciters(recitersUrl: language.reciters)
            state = .loaded(reciters)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func filteredSorted(_ reciters: [Reciter]) -> [Reciter] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var result = reciters

        if !q.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(q) }
        }

        result.sort { sortAscending ? ($0.name < $1.name) : ($0.name > $1.name) }
        return result
    }
}
