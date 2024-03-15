//
//  ContentView.swift
//  Mini04
//
//  Created by Leonardo Mota on 15/03/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var VM = ApresentacoesViewModel()
    @State var pastaName: String = ""
    @State var tempoDesejado: Int = 0
    let tempos = [5,10,15]
    @State var objetivo: String = ""
    
    var body: some View {
        NavigationStack {

            VStack {
                TextField(text: $pastaName) {
                    Text("Nome da pasta")
                }
                Picker("selecione", selection: $tempoDesejado) {
                    ForEach(tempos, id: \.self) { tempo in
                        Text(String(tempo))
                    }
                }

                TextField(text: $objetivo) {
                    Text("Objetivo")
                }
            }
            .padding()
            
            Button("Criar pasta") {
                let pasta = PastaModel(nome: pastaName, data: Date(), tempoDesejado: tempoDesejado, objetivoApresentacao: objetivo)
                VM.apresentacoes.pastas.append(pasta)
            }
            
            if !VM.apresentacoes.pastas.isEmpty {
                ForEach(VM.apresentacoes.pastas) { pasta in
                    NavigationLink(pasta.nome, destination:
                                    PastaView(VM: VM,
                                              nome: pasta.nome,
                                              data: pasta.data,
                                              tempoDesejado: pasta.tempoDesejado,
                                              objetivo: pasta.objetivoApresentacao,
                                              pasta: pasta))
                    
                }
            }
        }
        
    }
}


struct PastaView: View {
    @ObservedObject var VM: ApresentacoesViewModel

    var nome: String
    var data: Date
    var tempoDesejado: Int
    var objetivo: String
    @State var pasta: PastaModel

    
    var body: some View {
        VStack {
            Text("NOME: \(nome)")
            Text("data: \(data)")
            Text("tempoDesejado: \(tempoDesejado)")
            Text("objetivo: \(objetivo)")
            
            Button("Criar treino") {
                var treino = TreinoModel(data: Date(), pasta: pasta)
                pasta.treinos.append(treino)
            }
            if !pasta.treinos.isEmpty {
                ForEach(pasta.treinos) { treino in
                    NavigationLink(treino.nome, destination:
                                    TreinoView(pasta: pasta, treino: treino))
                }
            }
        }
    }
}

struct TreinoView: View {
    var pasta: PastaModel
    var treino: TreinoModel
    
    var body: some View {
        Text("PERTENCO A PASTA \(pasta.nome)")
    }
}

class ApresentacoesViewModel: ObservableObject {
    @Published var apresentacoes = Apresentacoes(pastas: [])
}


#Preview {
    ContentView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
