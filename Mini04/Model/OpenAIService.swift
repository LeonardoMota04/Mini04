//
//  OpenAIService.swift
//  Mini04
//
//  Created by Victor Dantas on 18/03/24.
//

import Foundation

class OpenAIService {
    
    // Endpoint URL
    private let endpointURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    func sendMessage(messages: [Message]) async -> CompletionResponse? {
        
        // MARK: Mapeando as mensagens individualmente e atribuindo ao array openAIMessages
        let openAIMessages = messages.map { message in
                    Message(role: message.role, content: message.content)
                }
        
        // MARK: Cria a Request
        let request = Request(model: "gpt-3.5-turbo", temperature: 0.5, messages: openAIMessages)
        
        // MARK: Codifica o objeto Request em um JSON
        guard let bodyData = try? JSONEncoder().encode(request) else {      // Tenta codificar, e envia um print de erro caso não consiga
            print("Failed to encode request body")
            return nil
        }
        
        // MARK: Configurando URLRequest
        // --> Tudo aqui é o mínimo necessário para fazer uma requisição na api do ChatGPT
        var urlRequest = URLRequest(url: endpointURL)   // Cria uma nova request para o endpoint especificado
        urlRequest.httpMethod = "POST"                  // Método da request - POST, GET etc.
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")         // Header Content-Type
        urlRequest.setValue("Bearer \(ProcessInfo.processInfo.environment["OPENAI_API_KEY2"] ?? "")", forHTTPHeaderField: "Authorization")       // Autorização Bearer usando a key
        urlRequest.httpBody = bodyData              // Atribui o JSON criado ao httpBody a partir do Model Request
        
        // MARK: Envia a request assíncrona e trata a resposta
        do {
            
//            print("HTTP Headers: \(String(describing: urlRequest.allHTTPHeaderFields))")    // debug
//            print(urlRequest)                                                               // debug
            
            let (data, _) = try await URLSession.shared.data(for: urlRequest)               // Tenta fazer o request e armazena em "data"
            let response = try JSONDecoder().decode(CompletionResponse.self, from: data)    // Com a data, decoda o JSON recebido para o formato do objeto CompletionResponse
            return response
            
        } catch {
            print("Error sending request: \n - \(error.localizedDescription) \n\nError details: \n - \(error)")  // erro
            return nil
        }
    }
}

