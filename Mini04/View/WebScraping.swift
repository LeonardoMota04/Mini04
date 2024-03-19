//
//  WebScrappingView.swift
//  TestandoCloudKitGPT
//
//  Created by Leonardo Mota on 14/03/24.
//

import SwiftUI
import SwiftSoup


// MARK: - MODEL
// SINONIMOS INFOS
struct SynonymsInfo {
    let word: String
    let num_synonyms: Int
    let num_contexts: Int
    //let synonymsInfo: [[String : Any]]
    let synonymsInfo: [SynonymContext]
}

struct SynonymContext: Decodable, Hashable {
    let context: String
    let synonyms: [String]
}


// Função para obter os sinônimos de u ma palavra
func getSynonymInfo(for word: String, completion: @escaping (Result<SynonymsInfo, Error>) -> Void) {
    do {
        // URL
        guard let url = URL(string: "https://www.sinonimos.com.br/\(word.lowercased())/") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválido"])))
            return
        }
        
        // SESSION
        let session = URLSession.shared
        
        // TASK
        let task = session.dataTask(with: url) { data, response, error in
            // Verifica se ocorreu algum erro
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Verifica se os dados foram recebidos com sucesso
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Nenhum dado recebido"])))
                return
            }
            
            do {
                // Analisa os dados
                let html = String(data: data, encoding: .utf8)!
                let doc: Document = try SwiftSoup.parse(html)
                
                // Obtém o número de sinônimos
                let numOfSynonymsText = try doc.select("p.word-count strong").text()
                let numOfSynonyms = Int(numOfSynonymsText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
                
                // Obtém o número de contextos
                let contexts = try doc.select(".content-detail")
                let numOfContexts = contexts.count - 1 // Ignora o último
                
                // Obtém os sinônimos por contexto
                var synonymsInfo: [SynonymContext] = []
                let numOfSynonymsToTake = 3
                
                for i in 0..<numOfContexts {
                    let context = contexts[i]
                    let contextNameToFix = try context.select(".content-detail--subtitle").text()
                    let contextName = contextNameToFix.replacingOccurrences(of: ":", with: "")
                    
                    var synonyms: [String] = []
                    let synonymElements = try context.select("p.syn-list a.sinonimo")
                    for j in 0..<min(synonymElements.count, numOfSynonymsToTake) {
                        let synonym = try synonymElements.get(j).text()
                        synonyms.append(synonym)
                    }
                    
                    let synonymContext = SynonymContext(context: contextName, synonyms: synonyms)
                    synonymsInfo.append(synonymContext)
                }
                
                // Cria o objeto SynonymsInfo
                let synonymsInfos = SynonymsInfo(word: word, num_synonyms: numOfSynonyms, num_contexts: numOfContexts, synonymsInfo: synonymsInfo)
                
                // Chama a conclusão com sucesso
                completion(.success(synonymsInfos))
            } catch {
                // Chama a conclusão com erro
                completion(.failure(error))
            }
        }
        
        // Inicia a tarefa
        task.resume()
    }
}


struct WebScrappingView: View {
    @State private var word = ""
    @State private var synonymsInfo: SynonymsInfo?
    
    var body: some View {
        VStack {
            TextField("Digite uma palavra", text: $word)
                .padding()
            
            Button("Obter Sinônimos") {
                fetchSynonyms()
            }
            .padding()
            
            Divider()
            
            if let synonymsInfo = synonymsInfo {
                SynonymsListView(synonymsInfo: synonymsInfo)
            }
        }
        .padding()
    }
    
    func fetchSynonyms() {
        // Chama a função getSynonymInfo com a palavra e um bloco de conclusão
        getSynonymInfo(for: word.lowercased()) { result in
            switch result {
            case .success(let synonymsInfo):
                // Se a operação for bem-sucedida, atualize a variável @State synonymsInfo
                DispatchQueue.main.async {
                    self.synonymsInfo = synonymsInfo
                }
            case .failure(let error):
                // Se ocorrer um erro, exiba a mensagem de erro
                DispatchQueue.main.async {
                    self.synonymsInfo = nil // Limpa os sinônimos, se houver
                }
            }
        }
    }

}




// LISTA DE SINONIMOS
struct SynonymsListView: View {
    let synonymsInfo: SynonymsInfo
    
    var body: some View {
        List {
            Text("Palavra: \(synonymsInfo.word)")
                .font(.headline)
                .padding(.bottom)

            Text("Número de Sinônimos: \(synonymsInfo.num_synonyms)")
                .padding(.bottom)

            Text("Número de Contextos: \(synonymsInfo.num_contexts)")
                .padding(.bottom)
            
            ForEach(synonymsInfo.synonymsInfo, id: \.context) { synonymContext in
                VStack(alignment: .leading) {
                    Text("Contexto: \(synonymContext.context)")
                        .font(.headline)
                    
                    ForEach(synonymContext.synonyms, id: \.self) { synonym in
                        Text("Sinônimo: \(synonym)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .padding(.vertical, 5)
            }
        }
    }
}






#Preview {
    WebScrappingView()
}
