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
    @EnvironmentObject var cameraVC: CameraViewModel
    var body: some View {
        GeometryReader(content: { geometry in
            let size = geometry.size
            ZStack {
//                 VideoPlayer(player: AVPlayer(url: url))
//                .aspectRatio(contentMode: .fill)
//                .frame(width: size.width, height: size.height)
                VideoPlayer(player: self.cameraVC.videoPlayer)
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    .frame(width: size.width * 0.5, height: size.height * 0.5)
                VStack {
                    ForEach(0..<cameraVC.topicTime.count, id: \.self) { index in
                        VStack {
                            Button {
                                cameraVC.seekPlayerVideo(topic: index)
                            } label: {
                                Text("Time topico: \(index)")
                            }
                        }
                    }
                }
            }
        })
        .padding()
    }
}
