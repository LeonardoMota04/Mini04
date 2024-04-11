//
//  Mini04App.swift
//  Mini04
//
//  Created by Leonardo Mota on 15/03/24.
//

import SwiftUI
import SwiftData

@main
struct Mini04App: App {
    @StateObject var camVM = CameraViewModel()
    
    //Variável que pega o tamanho do monitor
    let screenSize = NSScreen.main?.visibleFrame.size // Obter o tamanho visível do monitor principal


    var modelContainer: ModelContainer = {
        let schema = Schema([
            PastaModel.self,
            ApresentacaoModel.self,
            TreinoModel.self,
            FeedbackModel.self,
            RepeatedWordsModel.self
            //SynonymContext.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(camVM)
                //utiliza do 2/3 do tamanho da tela pra dimensionar o aplicativo ou 800x600px
                .frame(minWidth: (screenSize?.width ?? 800) * (2/3), minHeight: (screenSize?.height ?? 600) * (2/3)) // Define o tamanho mínimo da janela
//                .onAppear {
//                    let menuItem = NSMenuItem()
//                    menuItem.keyEquivalent = "a"
//                    menuItem.keyEquivalentModifierMask = [.command]
//                    menuItem.action = #selector(addNewTraining)
//                }

        }
        
//        .windowStyle(HiddenTitleBarWindowStyle())
        .modelContainer(modelContainer)
        //.modelContainer(sharedModelContainer)
        
    }
    
//    @objc func addNewTraining() {
//        NavigationLink("Adicionar novo treino", destination: RecordingVideoView(folderVM: folderVM))
//    }
}
