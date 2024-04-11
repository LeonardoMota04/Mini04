//
//  ChatGPTModels.swift
//  Mini04
//
//  Created by Victor Dantas on 18/03/24.
//

import Foundation

// MARK: - CHATGPT API MODELS
// Message structure
struct Message: Codable, Hashable {
//    var id = UUID()
    let role: String                     // role change
    let content: String
}

// Sums all the content for each one of the elements when the Element is of type Message
extension Array where Element == Message {
    var contentCount: Int { reduce(0, { $0 + $1.content.count })}
}

// Stores the possibles roles for the message
enum Role: Codable {
    case system
    case user
    case assistant
}

// Constains what's needed to do a request
struct Request: Codable {
    let model: String
    let temperature: Double
    let messages: [Message]
}

// Error
struct ErrorRootReponse: Decodable {
    let error: ErrorResponse
}
struct ErrorResponse: Decodable {
    let message: String
    let type: String?
}

struct CompletionResponse: Decodable {
    let choices: [Choice]
    let usage: Usage?
}

// Model which contains the total tokens used in the conversation
struct Usage: Decodable {
    let totalTokens: Int?
}

struct Choice: Decodable {
    let message: Message
    let finishreason: String?
}

// MARK: - Debugging
//extension Message {
//    private enum CodingKeys: String, CodingKey {
//        case role
//        case content
//    }
//    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        let rawRole = try? values.decode(String.self, forKey: .role)
//        let rawContent = try? values.decode(String.self, forKey: .content)
//        
//        guard let role = rawRole,
//              let content = rawContent
//        else {
//            throw ResponseError.missingData
//        }
//        
//        self.role = role
//        self.content = content
//    }
//}
//
//enum ResponseError: Error {
//    case missingData
//    case networkError
//    case unexpectedError(error: Error)
//}
