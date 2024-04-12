//
//  OpenAIService.swift
//  Mini04
//
//  Created by Victor Dantas on 18/03/24.
//

import Foundation

class OpenAIService {
    
    // Endpoint
    private let endpointURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    func sendMessage(messages: [Message]) async -> CompletionResponse? {
        
        // Mapping all individual messages and creating an unique message out of each one of them
        let openAIMessages = messages.map { message in
                    Message(role: message.role, content: message.content)
                }
        
        // Creating the request
        let request = Request(model: "gpt-3.5-turbo", temperature: 0.5, messages: openAIMessages)
        
        // Codifies the request object into JSON data
        guard let bodyData = try? JSONEncoder().encode(request) else {
            print("Failed to encode request body")
            return nil
        }
        
        // Configuring the URLRequest
        var urlRequest = URLRequest(url: endpointURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = bodyData
        
        // Sends the request async and treats the response
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let response = try JSONDecoder().decode(CompletionResponse.self, from: data)
            return response
        } catch {
            print("Error sending request: \n\(error)")
            return nil
        }
    }
}

