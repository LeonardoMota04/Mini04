//
//  CameraPreview.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI

struct CameraPreview : View {
    @EnvironmentObject var cameraVC: CameraViewModel
    @State private var isCameraConfigured = false
    @State private var showPermissionAlert = false // Variável para controlar a exibição do alerta
    @Environment(\.presentationMode) var presentationMode // Para controlar o modo de apresentação

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            if isCameraConfigured {
                ZStack {
                    CameraRepresentable(size: size)
                    // Overlay em cima da mão
                    CameraOverlayView(size: size)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: size.width, height: size.height)
                    .onAppear {
                        cameraVC.cameraGravando = true
                        // Depois que configurar a sessão, inicia a sessão
                        cameraVC.checkPermissions { success in
                            if success {
                                isCameraConfigured = true
                            } else {
                                showPermissionAlert = true // Mostrar alerta se as permissões não foram concedidas
                            }
                        }
                    }
                    .alert(isPresented: $showPermissionAlert) {
                        Alert(
                            title: Text("Permissões Necessárias"),
                            message: Text("Para utilizar a câmera e o áudio, é necessário conceder as permissões."),
                            primaryButton: .default(Text("Conceder")) {
                                // Abre as configurações de segurança para que o usuário possa conceder as permissões manualmente
                                if let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                                    NSWorkspace.shared.open(settingsURL)
                                }
                                self.presentationMode.wrappedValue.dismiss()

                            },
                            secondaryButton: .cancel(Text("Cancelar")) {
                                
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        )
                    }
            }
        }
        .background(Color.black)
        .onDisappear {
            cameraVC.cameraGravando = false
            isCameraConfigured = false
            cameraVC.stopSession()
        }
    }
}
