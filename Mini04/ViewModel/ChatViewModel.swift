//
//  ChatViewModel.swift
//  Mini04
//
//  Created by Victor Dantas on 19/03/24.
//

import Foundation

class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    
    private let openAIService = OpenAIService()
    
    func sendMessage(content: String) {
        let newMessage = Message(role: "user", content: content) // ROLE CHANGE
        messages.append(newMessage)
        
        Task {
            // Sends the message and awaits the response
            guard let response = await openAIService.sendMessage(messages: messages) else {
                print("\nFailed to receive a valid response from the server.")
                return
            }
            
            // Verifies if are there any choices in the response
            guard let firstChoice = response.choices.first else {
                print("\nNo choices found in the response.")
                return
            }
            
            // Adds the received message in the message list
            let receivedMessage = firstChoice.message
            
            DispatchQueue.main.async {
                self.messages.append(receivedMessage)
            }
        }
    }
}

