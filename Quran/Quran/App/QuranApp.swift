//
//     QuranApp.swift
//     Quran
//
//  Created by maimona alzaidi on 07/06/1447 AH.
//
import SwiftUI

@main
struct QuranApp: App {
    @StateObject private var appVM = AppViewModel()
    @StateObject private var playerVM = PlayerViewModel()

    var body: some Scene {
        WindowGroup {
            
            RootView()
                .environmentObject(appVM)
                .environmentObject(playerVM)
                .preferredColorScheme(appVM.themeMode.colorScheme)
        }
    }
}
