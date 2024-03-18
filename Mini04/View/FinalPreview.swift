//
//  FinalPreview.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI
import AVKit

struct FinalPreview: View {
    var url: URL
    var body: some View {
        GeometryReader(content: { geometry in
            let size = geometry.size
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
        })
        .padding()
    }
}

