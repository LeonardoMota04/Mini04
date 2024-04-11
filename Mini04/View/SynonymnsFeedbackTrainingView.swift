//
//  SynonymnsFeedbackTrainingView.swift
//  Mini04
//
//  Created by Leonardo Mota on 04/04/24.
//

import SwiftUI



// MARK: - SINONIMOS FEEDBACK TREINO VIEW
struct SynonymsFeedbackTrainingView: View {
    // recebe um array de palavras repetidas naquele treino
    let repeatedWordsArray: [RepeatedWordsModel]

    var body: some View {
        ZStack (alignment: .leading){
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("light_Orange"), lineWidth: 2)
                .fill(Color("light_White"))
            
            VStack(alignment: .leading, spacing: 0) {
                // HEADER
                VStack (alignment: .leading, spacing: 5) {
                    let stringPalavras = repeatedWordsArray.count > 1 ? "Palavras" : "Palavra"
                    let stringRepetidas = repeatedWordsArray.count > 1 ? "Repetidas" : "Repetida"
                    Text("\(repeatedWordsArray.count) \(stringPalavras)")
                        .font(.title2)
                        .foregroundStyle(.black)
                        .bold()
                    
                    Text("\(stringRepetidas) em excesso")
                        .foregroundStyle(.ultraThinMaterial)
                        .font(.footnote)
                }
                .padding(20)
                
                // QUADRO COM SINONIMOS
                SynonymsFrameBoardView(repeatedWordsArray: repeatedWordsArray)
            }
        }
    }
}



// MARK: - QUADRO COM SINONIMOS
struct SynonymsFrameBoardView: View {
    let repeatedWordsArray: [RepeatedWordsModel]
    @State private var selectedWord: String? // para armazenar a palavra repetida clicada
    @State private var repeatedTimes: Int = 0
    @State private var filteredWords: [RepeatedWordsModel] = []

    var body: some View {
           
           VStack(alignment: .leading, spacing: 0) { // vstack geral
               
               HStack(spacing: 15) { // hstack para palavras repetidas
                   // MARK: - PALAVRAS REPETIDAS LISTADAS (MAIS REPETIDA PARA MENOS)
                   ForEach(filteredWords.prefix(8), id: \.self) { repeatedWord in
                       Text(repeatedWord.word)
                           .bold(selectedWord == repeatedWord.word ? true : false)
                           .foregroundStyle(selectedWord == repeatedWord.word ? (Color.lightOrange) : (Color.lightLighterOrange))
                           .padding(selectedWord == repeatedWord.word ? 16 : 10)
                           .background(selectedWord == repeatedWord.word ? (Color.lightLighterOrange) : (Color.lightOrange))
                           .clipShape(selectedWord == repeatedWord.word ? UnevenRoundedRectangle(cornerRadii: .init(topLeading: 6, topTrailing: 6)) : UnevenRoundedRectangle(cornerRadii: .init(topLeading: 6, bottomLeading: 6, bottomTrailing: 6, topTrailing: 6)))
                           .overlay {
                               VStack {
                                   HStack {
                                       Spacer()
                                       Text("\(repeatedWord.repetitionCount)") // Bola em cima mostrando quantas vezes foi repetida
                                           .foregroundStyle(selectedWord == repeatedWord.word ? (Color.lightLighterGray) : (Color.lightOrange))
                                           .padding(6)
                                           .background(selectedWord == repeatedWord.word ? (Color.lightOrange) : (Color.lightLighterOrange))
                                           .clipShape(Circle())
                                           .offset(x: 10, y: -10)
                                   }
                                   Spacer()
                               }
                           }
                           .onTapGesture {
                               selectedWord = repeatedWord.word
                               repeatedTimes = repeatedWord.repetitionCount
                           }
                   }
               }
            
            // MARK: - QUADRO DE SINONIMOS
               UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 6, bottomTrailing: 6, topTrailing: 6))
                   .foregroundStyle(Color.lightLighterOrange)
                   .overlay {
                       VStack(alignment: .leading) {
                           Text("Você repetiu essa palavra \(Text(String(repeatedTimes)).bold()) vezes.")
                               .font(.body)
                               .foregroundStyle((Color.lightOrange))

                           Divider()
                               .padding(.trailing, 40)
                               .padding(.vertical, 5)
                               .foregroundStyle((Color.lightOrange))
                           
                           // Verifica se a palavra clicada está presente no array de palavras repetidas
                           if let repeatedWord = repeatedWordsArray.first(where: { $0.word == selectedWord }) {
                               Text(repeatedWord.numSynonyms > 0  ? "Possíveis sinônimos:" : "Infelizmente não encontramos possíveis sinônimos para '\(repeatedWord.word)'.")
                                   .foregroundStyle(Color(.darkGray))
                                   .font(.body)
                                   .bold()
                          
                               // CONTEXTO COM (3) SINONIMOS
                               HStack(alignment: .top, spacing: 100) {
                                   // Ordenar os contextos com base no número de sinônimos
                                   let sortedContexts = repeatedWord.synonymContexts.sorted { $0.count > $1.count }
                                   
                                   // Primeira coluna com até 3 contextos e sinônimos
                                   VStack(alignment: .leading, spacing: 34) {
                                       ForEach(sortedContexts.prefix(3), id: \.self) { contextWithSynonyms in
                                           VStack(alignment: .leading) {
                                               // CONTEXTO
                                               if let context = contextWithSynonyms.first, context.first?.isUppercase == true {
                                                   Text(context)
                                                       .font(.footnote)
                                                       .foregroundStyle(.gray)
                                                   
                                                   // SINONIMOS
                                                   HStack {
                                                       ForEach(contextWithSynonyms.dropFirst(), id: \.self) { synonym in
                                                           Text(synonym)
                                                               .font(.subheadline)
                                                               .foregroundStyle(.black)
                                                               .padding(8)
                                                               .background(Color.lightWhite)
                                                               .clipShape(RoundedRectangle(cornerRadius: 6))
                                                       }
                                                   }
                                               } else {
                                                   // SINONIMOS
                                                   HStack {
                                                       ForEach(contextWithSynonyms.dropFirst(), id: \.self) { synonym in
                                                           Text(synonym)
                                                               .font(.subheadline)
                                                               .foregroundStyle(.black)
                                                               .padding(8)
                                                               .background(Color.lightWhite)
                                                               .clipShape(RoundedRectangle(cornerRadius: 6))
                                                       }
                                                   }
                                               }
                                           }
                                           .padding([.top, .leading], 10)
                                       }
                                   }
                                   // Segunda coluna para contextos e sinônimos adicionais, se houver
                                   if repeatedWord.numContexts > 3 {
                                       VStack(alignment: .leading, spacing: 34) {
                                           ForEach(sortedContexts.dropFirst(3), id: \.self) { contextWithSynonyms in
                                               VStack(alignment: .leading) {
                                                   // CONTEXTO
                                                   if let context = contextWithSynonyms.first, context.first?.isUppercase == true {
                                                       Text(context)
                                                           .font(.footnote)
                                                           .foregroundStyle(.gray)

                                                       // SINONIMOS
                                                       HStack {
                                                           ForEach(contextWithSynonyms.dropFirst(), id: \.self) { synonym in
                                                               Text(synonym)
                                                                   .font(.subheadline)
                                                                   .foregroundStyle(.black)
                                                                   .padding(8)
                                                                   .background(Color.lightWhite)
                                                                   .clipShape(RoundedRectangle(cornerRadius: 6))
                                                           }
                                                       }
                                                   } else {
                                                       // SINONIMOS
                                                       HStack {
                                                           ForEach(contextWithSynonyms.dropFirst(), id: \.self) { synonym in
                                                               Text(synonym)
                                                                   .font(.subheadline)
                                                                   .foregroundStyle(.black)
                                                                   .padding(8)
                                                                   .background(Color.lightWhite)
                                                                   .clipShape(RoundedRectangle(cornerRadius: 6))
                                                           }
                                                       }
                                                   }
                                               }
                                               .padding([.top, .leading], 10)
                                           }
                                       }
                                   }
                               }
                           }
                           Spacer() // para jogar o que esta dentro do quadrão para cima
                       }
                       .padding([.horizontal, .top])
                   }

        }
        .padding([.horizontal, .bottom], 20)
        .onAppear {
            // Filtrar e classificar as palavras repetidas
            let sortedWords = repeatedWordsArray.sorted(by: { $0.repetitionCount > $1.repetitionCount })
            
            // Definir a primeira palavra como selectedWord e repeatedTimes, se houver palavras filtradas
            if let firstWord = sortedWords.first {
                selectedWord = firstWord.word
                repeatedTimes = firstWord.repetitionCount
            }
            
            // Aqui você pode aplicar mais filtros ou processamentos conforme necessário
            filteredWords = sortedWords
        }
    }
}

struct SynonymsFrameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        SynonymsFrameBoardView(repeatedWordsArray: [RepeatedWordsModel(word: "exemplo", numSynonyms: 10, numContexts: 10), RepeatedWordsModel(word: "Outra", numSynonyms: 10, numContexts: 10)])

    }
}
