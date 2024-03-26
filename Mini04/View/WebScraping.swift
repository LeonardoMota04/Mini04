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
    let synonymsInfo: [SynonymContext]
}

struct SynonymContext: Hashable {
    let context: String
    let synonyms: [String]
}


// Classe para gerenciar chamadas de rede
class NetworkManager {
    static func fetchData(for word: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Normaliza a palavra (remove acentuações e converte para minúscula)
        let normalizedWord = word.folding(options: .diacriticInsensitive, locale: nil).lowercased()
        
        guard let url = URL(string: "https://www.sinonimos.com.br/\(normalizedWord)/") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválido"])))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Nenhum dado recebido"])))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
}

// Classe para analisar dados HTML
class HTMLParser {
    static func parseHTML(data: Data, word: String, completion: @escaping (Result<SynonymsInfo, Error>) -> Void) {
        do {
            let html = String(data: data, encoding: .utf8)!
            let doc: Document = try SwiftSoup.parse(html)
            
            let numOfSynonymsText = try doc.select("p.word-count").text()
            let components = numOfSynonymsText.components(separatedBy: CharacterSet.decimalDigits.inverted)
            let numbers = components.compactMap { Int($0) }
            
            var numOfSynonyms = 0
            var numOfContexts = 0
            var shouldGetContextName = false
            
            if numbers.count == 2 {
                numOfContexts = numbers[1]
                shouldGetContextName = true
            } else {
                let contexts = try doc.select(".content-detail--subtitle")
                numOfContexts = contexts.count - 1
            }
            
            let contexts = try doc.select(".content-detail")
            var synonymsInfo: [SynonymContext] = []
            let numOfSynonymsToTake = 3
            
            for i in 0..<numOfContexts {
                let context = contexts[i]
                var contextName: String?
                
                if shouldGetContextName, let contextSubtitle = try? context.select(".content-detail--subtitle").first()?.text() {
                    contextName = contextSubtitle.replacingOccurrences(of: ":", with: "")
                }
                
                var synonyms: [String] = []
                let synonymElements = try context.select("p.syn-list").select("a.sinonimo, span:not([class])")
                
                for j in 0..<min(synonymElements.count, numOfSynonymsToTake) {
                    let synonym = try synonymElements.get(j).text()
                    numOfSynonyms += 1
                    synonyms.append(synonym)
                }
                
                let synonymContext = SynonymContext(context: contextName ?? "\(i + 1)", synonyms: synonyms)
                synonymsInfo.append(synonymContext)
            }
            
            let synonymsInfos = SynonymsInfo(word: word, num_synonyms: numOfSynonyms, num_contexts: numOfContexts, synonymsInfo: synonymsInfo)
            completion(.success(synonymsInfos))
            
        } catch {
            completion(.failure(error))
        }
    }
}


struct WebScrappingView: View {
    @State private var word = ""
    @State private var synonymsInfo: SynonymsInfo?
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            TextField("Digite uma palavra", text: $word)
                .padding()
            
            Button("Obter Sinônimos") {
                fetchSynonyms()
            }
            .padding()
            
            Divider()
            
            if isLoading {
                ProgressView("Carregando...")
            } else if let synonymsInfo = synonymsInfo {
                SynonymsListView(synonymsInfo: synonymsInfo)
            }
        }
        .padding()
    }
    
    // CHAMADA DE REDE -> PARSER HTML -> RESULTADO INFOS SINONIMOS
    func fetchSynonyms() {
        isLoading = true
        
        // CHAMADA DE REDE
        NetworkManager.fetchData(for: word) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let data):
                    // PARSER HTML
                    HTMLParser.parseHTML(data: data, word: self.word.lowercased()) { result in
                        switch result {
                        case .success(let synonymsInfo):
                            self.synonymsInfo = synonymsInfo
                        case .failure(let error):
                            self.synonymsInfo = nil
                        }
                    }
                case .failure(let error):
                    self.synonymsInfo = nil
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
            
            ForEach(synonymsInfo.synonymsInfo, id: \.self) { synonymContext in
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
