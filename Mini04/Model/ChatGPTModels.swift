//
//  ChatGPTModels.swift
//  Mini04
//
//  Created by Victor Dantas on 18/03/24.
//

import Foundation

// MARK: - CHATGPT API MODELS
// Estrutura da mensagem
struct Message: Codable, Hashable {
    let role: String             // O responsável pela mensagem (user ou assistant)
    let content: String          // O conteúdo da mensagem
}

// Sums all the content for each one of the elements when the Element is of type Message
//
//extension Array where Element == Message {
//    var contentCount: Int { reduce(0, { $0 + $1.content.count })}
//}

// Objeto Request contém o necessário para fazer uma Request
struct Request: Codable {
    let model: String           // Qual modelo do ChatGPT estamos fazendo a request - ATUAL: "gpt-turbo-3.5"
    let temperature: Double     // Determina a "seriedade" das respostas da API     - ATUAL: 0.5
    let messages: [Message]     // Array de Message
}

/// Error
///struct ErrorRootReponse: Decodable {
///    let error: ErrorResponse
///}
///struct ErrorResponse: Decodable {
///    let message: String
///    let type: String?
///}

// Objeto da resposta recebida da request
struct CompletionResponse: Decodable {
    let choices: [Choice]               // A resposta fica dentro das choices (Em alguns casos, o GPT têm duas opções de resposta. Essas opções são as choices)
    let usage: Usage?                   // Armazena o número de tokens usados na requisição
}

// Objeto das Choices
struct Choice: Decodable {
    let index: Int?             // Index da choice
    let message: Message        // A mensagem presente nesta choice
    let finishreason: String?   // O motivo da mensagem ter sido finalizada ? não tenho certeza
}

// Armazena o número de tokens usados na requisição
struct Usage: Decodable {
    let totalTokens: Int?       // Nesse caso, armazenando apenas o total de tokens utilizados na requisição. - Pode-se armazenar o número de tokens por role (user / assistant)
}

// MARK: - Debugging
// Método de debug que percorre os elementos da Message separadamente
extension Message {
    private enum CodingKeys: String, CodingKey {
        case role
        case content
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawRole = try? values.decode(String.self, forKey: .role)
        let rawContent = try? values.decode(String.self, forKey: .content)
        
        guard let role = rawRole,
              let content = rawContent
        else {
            throw ResponseError.missingData
        }
        
        self.role = role
        self.content = content
    }
}

enum ResponseError: Error {
    case missingData
    case networkError
    case unexpectedError(error: Error)
}
