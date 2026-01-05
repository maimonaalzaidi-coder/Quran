
//
//  Quran
//
//  Created by Maimona Alzaidi on 10/06/1447 AH.

import Foundation
import AVFoundation
import SwiftUI
import Combine
@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var nowPlayingTitle: String? = nil
    @Published var isPlaying: Bool = false

    private var player: AVPlayer? = nil

    func play(url: URL, title: String) {
        nowPlayingTitle = title
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.play()
        isPlaying = true
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        nowPlayingTitle = nil
    }
}

struct NowPlayingBar: View {
    @EnvironmentObject private var playerVM: PlayerViewModel

    var body: some View {
        if let title = playerVM.nowPlayingTitle {
            HStack(spacing: 12) {
                Text(title)
                    .lineLimit(1)
                    .font(.footnote)

                Spacer()

                Button(playerVM.isPlaying ? "Pause" : "Play") {
                    playerVM.togglePlayPause()
                }
                .buttonStyle(.borderedProminent)

                Button("Stop") {
                    playerVM.stop()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}
