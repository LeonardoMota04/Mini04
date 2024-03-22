//
//  ChatView.swift
//  Mini04
//
//  Created by Victor Dantas on 19/03/24.
//

//import SwiftUI
//
//struct ChatView: View {
//    @StateObject var viewModel = ChatViewModel()
//    @State private var newMessage = ""
//    
//    var body: some View {
//        VStack {
//            ScrollView {
//                ForEach(viewModel.messages, id: \.self) { message in
//                    Text("\(message.role): \(message.content)")
//                }
//            }
//            
//            HStack {
//                TextField("Enter a message...", text: $newMessage)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                
//                Button("Send") {
//                    sendMessage()
//                }
//                .padding(.trailing)
//            }
//        }
//        .padding()
//    }
//    
//    private func sendMessage() {
//        viewModel.sendMessage(content: newMessage)
//        newMessage = ""
//    }
//}
//
//#Preview {
//    ChatView()
//}
