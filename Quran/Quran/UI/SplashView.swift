//
//  Quran
//
//  Created by Maimona Alzaidi on 07/06/1447 AH.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 16) {

            Image("LOGOw") //
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)

            Text("Quran Reciters")
                .font(.largeTitle)
                .bold()

            Text("mp3quran")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
