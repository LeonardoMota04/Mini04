//
//  RecordingVideoView.swift
//  Mini04
//
//  Created by luis fontinelles on 17/03/24.
//

import SwiftUI

struct RecordingVideoView: View {
    @EnvironmentObject var camVM: CameraViewModel
    @State var isPreviewShowing = false
    var body: some View {
        GeometryReader { reader in
            VStack {
                CameraPreview()
//                    
                HUDCameraView(isPreviewShowing: $isPreviewShowing)
                    .frame(maxWidth: reader.size.width)
                    .frame(height: reader.size.height*0.1)
            }
            
        }
        .overlay(content: {
            if let url = camVM.urltemp, isPreviewShowing {
                FinalPreview(url: url)
                    .transition(.move(edge: .trailing))
            }
        })
        .animation(.easeInOut, value: isPreviewShowing)

    }
}

#Preview {
    RecordingVideoView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

