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
    @State private var folderViewModels: [UUID: FoldersViewModel] = [:] // instanciando viewmodel das pastas

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
//            SwiftDataView()
            ContentView()
//            RecordingVideoView()
                .environmentObject(camVM)

        }
        //.modelContainer(sharedModelContainer)
    }
}
