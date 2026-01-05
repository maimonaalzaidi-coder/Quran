//
//  Quran
//
//  Created by Maimona Alzaidi on 11/06/1447 AH.


import SwiftUI
import Combine
struct ReciterDetailsView: View {
    let reciterId: Int
    let recitersUrl: String
    let suwarById: [Int: Surah]

    @EnvironmentObject private var playerVM: PlayerViewModel
    @StateObject private var vm = ReciterDetailsVM()

    var body: some View {
        content
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await vm.load(recitersUrl: recitersUrl, reciterId: reciterId)
            }
            .safeAreaInset(edge: .bottom) {
                NowPlayingBar()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            VStack(spacing: 10) {
                Text("Failed to load details")
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    Task { await vm.load(recitersUrl: recitersUrl, reciterId: reciterId) }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let reciter):
            List {
                Section("Reciter") {
                    Text(reciter.name).bold()
                }

                ForEach(reciter.moshaf) { m in
                    Section(m.name) {
                        ForEach(m.surahIds, id: \.self) { sid in
                            let surahName = suwarById[sid]?.name ?? "Surah \(sid)"

                            Button {
                                if let url = buildAudioURL(server: m.server, surahId: sid) {
                                    playerVM.play(url: url, title: "\(reciter.name) — \(surahName)")
                                }
                            } label: {
                                HStack {
                                    Text(String(format: "%03d", sid))
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)

                                    Text(surahName)

                                    Spacer()

                                    Image(systemName: "play.circle")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func buildAudioURL(server: String, surahId: Int) -> URL? {
        let trimmed = server.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.hasSuffix("/") ? trimmed : (trimmed + "/")
        let file = String(format: "%03d.mp3", surahId)
        return URL(string: base + file)
    }
}

@MainActor
final class ReciterDetailsVM: ObservableObject {
    @Published var state: ViewState<Reciter> = .idle
    private let service = Mp3QuranService()

    func load(recitersUrl: String, reciterId: Int) async {
        state = .loading
        do {
            let reciter = try await service.fetchReciterDetails(recitersUrl: recitersUrl, reciterId: reciterId)
            state = .loaded(reciter)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
