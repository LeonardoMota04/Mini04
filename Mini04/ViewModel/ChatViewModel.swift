//
//  ChatViewModel.swift
//  Mini04
//
//  Created by Victor Dantas on 19/03/24.
//

import SwiftUI

class ChatViewModel: ObservableObject {
        
    @Published var messages: [Message] = []    // Array que contém todas as mensagens da conversa atual
    
    private let openAIService = OpenAIService()    // Instância da OpenAIService
    
    func sendMessage(content: String) {
        let newMessage = Message(role: "user", content: content)    // Cria uma nova mensagem com o conteúdo de uma string
        messages.append(newMessage)     // Adiciona a nova mensagem no array de mensagens
        
        // MARK: Task assíncrona
        Task {
            // Envia a mensagem e espera a resposta
            // O prompt é enviado com todas as mensagens já enviadas, para manutenção do contexto da conversa
            guard let response = await openAIService.sendMessage(messages: messages) else {
                print("\nFailed to receive a valid response from the server.")
                return
            }
            
            // Verifica se há mais de uma choice na resposta
            if response.choices.count > 1 {
                // LÓGICA PARA LIDAR COM MAIS DE UMA CHOICE
            } else {
                
                // Checa se existe uma choice
                guard let firstChoice = response.choices.first else {
                    print("\nNo choices found in the response.")
                    return
                }
                
                // Adiciona a mensagem recebida na lista de mensagens
                let receivedMessage = firstChoice.message
                
                DispatchQueue.main.async {
                    self.messages.append(receivedMessage)
                }
            }
        }
    }
}

