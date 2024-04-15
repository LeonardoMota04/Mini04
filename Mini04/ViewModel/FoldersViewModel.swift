//
//  FoldersViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData
import AVFoundation
import SwiftUI
import Combine

@Observable
class FoldersViewModel: ObservableObject {
    // MARK: - Modelo
    var folder: PastaModel
    var modelContext: ModelContext?
    
    // variaveis utilizaveis para salvar os dados
    var objetiveApresentation: String = ""
    var avaregeTime: TimeInterval = 0
    var formatedAvareTime: String = ""
    
    // Variaveis network
    private var openAIService = OpenAIService() // TODO: ver se isso aqui pode mesmo
    var messages: [Message] = []
    var messagePorcentages: Message = Message(role: "", content: "") // iniciando vazia
    let globalGroup = DispatchGroup() // dispatchgroup global nesse espoco para por todas as Tasks no mesmo Group
    var showLoadingView: Bool = false // variavel de controle para mostrar o loading
    
    init(folder: PastaModel, modelContext: ModelContext? = nil) {
        self.folder = folder
        self.modelContext = modelContext
        fetchTrainings()
    }
    
    // MARK: Networking -
    func sendMessage(content: String, completion: @escaping (Message?) -> Void) {
        let group = DispatchGroup() // criando o group
        let newMessage = Message(role: "user", content: content) // ROLE CHANGE
        messages.append(newMessage)
        
        Task {
            globalGroup.enter()
            // Sends the message and awaits the response
            guard let response = await openAIService.sendMessage(messages: messages) else {
                print("\nFailed to receive a valid response from the server.")
                completion(nil)
                return
            }
            
            // Verifies if are there any choices in the response
            guard let firstChoice = response.choices.first else {
                print("\nNo choices found in the response.")
                completion(nil)
                return
            }
            
            // Adds the received message in the message list
            let receivedMessage = firstChoice.message
            self.messagePorcentages = receivedMessage
            
            print(messagePorcentages)
            DispatchQueue.main.async {
                self.messages.append(receivedMessage)
                completion(receivedMessage)
                self.globalGroup.leave()
            }
        }
    }
    
    // MARK: - CRUD
    // CREATE
    func createNewTraining(videoURL: URL, videoScript: String, videoTime: TimeInterval, videoTopics: [String], topicsDuration: [TimeInterval], cutSpeeches: [String], speechStart: [TimeInterval]) {
        self.showLoadingView = true
        guard let modelContext = modelContext else { return }
        DispatchQueue.main.async {
            self.processFeedbacks(videoScript: videoScript) { [self] feedback in
                let newTraining = TreinoModel(name: "Treino \(folder.treinos.count + 1)",
                                              video: VideoModel(videoURL: videoURL,
                                                                script: videoScript,
                                                                videoTime: videoTime,
                                                                videoTopics: videoTopics,
                                                                topicsDuration: topicsDuration,
                                                                cutSpeeches: cutSpeeches,
                                                                speechStart: speechStart),
                                              feedback: feedback)
                
                do {
                    folder.treinos.append(newTraining)
                    modelContext.insert(newTraining)
                    try modelContext.save()
                    self.showLoadingView = false
                } catch {
                    print("Não conseguiu criar e salvar o treino. \(error)")
                }
            }
          
        }
    }
    
    // retorna o valor da data formatado - 01 de abril
    func formatterDate(date: Date) -> String  {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "dd 'de' MMMM"
        let portugueseDate = dateFormatter.string(from: date)
        return portugueseDate
    }
    
    // MARK: - FEEDBACKS
    func processFeedbacks(videoScript: String, completion: @escaping (FeedbackModel) -> Void) {
        let repeatedWords = filterRepeatedWordsOverFiveTimes(videoScript: videoScript)
        var repeatedWordFeedbacks: [RepeatedWordsModel] = []
        let group = DispatchGroup()
        
        for (word, _) in repeatedWords {
            group.enter()
            fetchSynonyms(for: word) { synonymsModel in
                if let synonymsModel = synonymsModel {
                    // Formatando a palavra para a primeira maiúscula sempre
                    let formattedWord = word.prefix(1).uppercased() + word.lowercased().dropFirst()
                    // Criando uma instância de RepeatedWordsModel com a palavra formatada
                    let repeatedWordModel = RepeatedWordsModel(word: formattedWord, repetitionCount: repeatedWords[word] ?? 0, numSynonyms: synonymsModel.numSynonyms, numContexts: synonymsModel.numContexts, synonymContexts: synonymsModel.synonymContexts)
                    repeatedWordFeedbacks.append(repeatedWordModel)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.sendMessage(content: "Considerando que as 3 principais características de uma apresentação coesa são: Fluidez do Discurso, Organização Lógica e Conexão entre Ideias. Me dê somente as porcentagens (sem texto explicativo, apenas as porcentagens) de cada  parâmetro (considerando que cada um vale 100% individualmente) analise a seguinte apresentação: \(videoScript)") { coherenceBrute in
                //            let retornoGPT:Message = Message(role: "assistant", content: "Fluidez do Discurso: 90%\nOrganização Lógica: 95%\nConexão entre Ideias: 100%")
                //            let coherence = self.convertPorcentageCohesionFeedback(message: retornoGPT)
                let feedback = FeedbackModel(coherence: 0, repeatedWords: repeatedWordFeedbacks, coherenceValues: self.convertPorcentageCohesionFeedback(message: coherenceBrute))
                completion(feedback)
            }
        }
    
    }
    // Função para buscar os sinônimos de uma palavra
    func fetchSynonyms(for word: String, completion: @escaping (RepeatedWordsModel?) -> Void) {
        NetworkManager.fetchData(for: word) { result in
            switch result {
            case .success(let data):
                HTMLParser.parseHTML(data: data, word: word) { result in
                    switch result {
                    case .success(let synonymsInfo):
                        completion(synonymsInfo)
                    case .failure:
                        completion(nil)
                    }
                }
            case .failure:
                completion(nil)
            }
        }
    }

    // filtra palavras e separa as repetidas 5 vezes, juntamente com o numero de vezes que foi repetida
    func filterRepeatedWordsOverFiveTimes(videoScript: String) -> [String: Int] {
        var normalizedText: [String: [String]] = [:]
        var repeatedWords: [String: Int] = [:]
        
        // Conta as palavras e normaliza o texto
        let words = videoScript.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            if !word.isEmpty {
                let normalizedWord = word.lowercased().folding(options: .diacriticInsensitive, locale: .current)
                if normalizedText[normalizedWord] == nil {
                    normalizedText[normalizedWord] = [word]
                } else {
                    normalizedText[normalizedWord]?.append(word)
                }
            }
        }
        
        // Conta as palavras repetidas
        for (_, words) in normalizedText {
            guard let firstWord = words.first else { continue }
            repeatedWords[firstWord, default: 0] += words.count
        }
        
        // Filtra as palavras repetidas mais de 5 vezes
        let repeatedWords_5 = repeatedWords.filter { $0.value >= 5 }
        
        return repeatedWords_5
    }
    
    // READ
    func fetchTrainings() {
        guard let modelContext = modelContext else { return }
        do {
            let fetchDescriptor = FetchDescriptor<TreinoModel>(
                sortBy: [SortDescriptor(\TreinoModel.nome)]
            )
            folder.treinos = try modelContext.fetch(fetchDescriptor)
            
            // imprimir resultados recuperados
            print("Treinos recuperados:")
            for training in folder.treinos {
                print("- Nome: \(training.nome)")
                print("- Data: \(training.data)")
                print("- Video: \(String(describing: training.video?.videoURL)) ?? nao tem vídeo nesse treino")
                print("\n\n\n\n")
            }
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    // DELETE
    func deleteTraining(_ training: TreinoModel) {
        guard let modelContext = modelContext else { return }
        
        if let index = folder.treinos.firstIndex(of: training) {
            do {
                folder.treinos.remove(at: index)
                modelContext.delete(training)
                try modelContext.save()
            } catch {
                print("Falha ao salvar após a exclusão do treino. \(error)")
            }
        }
    }
    
    // coloca o objetivo da pessoa (pitch, vendas, etc)
    func folderObjectiveSet(objetive: String) {
        self.objetiveApresentation = objetive
    }
    
    func calculateAvarageTime() {
        guard let modelContext = modelContext else { return }
        var totalTime: TimeInterval = 0
        // interando todos os treinos para conseguir o valor total do tempo gasto
        for treino in folder.treinos {
            totalTime += treino.video?.videoTime ?? 0
        }
        // calculando a media - media = total / quantidade
        self.avaregeTime = totalTime / Double(folder.treinos.count)
        // Atribuindo o valor a persistencia e salvando em seguida
        self.folder.avaregeTime = avaregeTime
        do {
            try modelContext.save()
        } catch {
            print("error ao salvar o tempo medio do folderVM")
        }
        // formatando o valor em uma string para ficar mais facil de colocar no UI - verificando se não é nulo pois cria a pasta com ele null
        if folder.avaregeTime != 0 {
            self.formatedAvareTime = formatVideoDuration(time: self.folder.avaregeTime)
        }
    }
    
    // Formata uma string com segundo minutos e horas
    func formatVideoDuration(time: TimeInterval) -> String {
        let totalSeconds = time
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return "00:00" // or do some error handling - cai aqui primeira vez que a pasta é criada
        }
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    
    func calculateTreinoTime(videoTime: Double) -> CGFloat {
        let totalSeconds = Double(folder.tempoDesejado)
        return CGFloat(videoTime) / CGFloat(totalSeconds) * 54
    }


    
    // tranforma o retorno do chatGTP em porcentagem par montar os graficos de feedback
    func convertPorcentageCohesionFeedback(message: Message?) -> [CGFloat] {
        // porcentagens do feecback de coesa
        var porcentages: [CGFloat] = []
        if message?.role == "assistant" {
            // Separando o retorno da API em uma array para pegar o valor de cada %
            guard let separeteValues = message?.content.split(separator: "\n")
            else { print("Erro no result GPT - convertProcetageCohesionFeedback")
                return []}
            
            for newMessage in separeteValues {
                // Dividir a mensagem pelo caractere ':'
                let components = newMessage.split(separator: ":")
                // Se houver mais de um componente, o último será a porcentagem e o primeiro o titulo
                if let porcentageComponent = components.last, let titleComponet = components.first {
                    // captando a porcentagem e retirando o ultimo caractere - exemplo "90%" tira o "%"
                    let porcentage = String(porcentageComponent).trimmingCharacters(in: .whitespaces).dropLast()
                    if let floatPorcentage = Float(porcentage) {
                        // verificando se não existe valores na array para evitar erro de out of index
                        if porcentages.count < 3 {
                            // Adiciona a porcentagem ao array
                            porcentages.append(CGFloat(floatPorcentage))
                        } else {
                            // verificando os titulos para conseguir colocar a porcentagem no local correto
                            if titleComponet.contains("Fluidez") {
                                porcentages[0] = CGFloat(floatPorcentage)
                            } else if titleComponet.contains("Organização") {
                                porcentages[1] = CGFloat(floatPorcentage)
                            } else if titleComponet.contains("Conexão") {
                                porcentages[2] = CGFloat(floatPorcentage)
                            }
                        }
                    }
                }
            }
        }
        // Exibe as porcentagens coletadas
        for porcentage in porcentages {
            print(porcentage)
        }
        return porcentages
    }
    
    // faz a media de todos os feedbacks de coesao criados na pasta para preencher o cohesion na pasta
    func avaregeCohesionFeedback() -> ((fluid: CGFloat, organization: CGFloat, conection: CGFloat)){
        var totalFluid: CGFloat = 0
        var totalOrganization: CGFloat = 0
        var totalConection: CGFloat = 0
        for treino in folder.treinos {
            totalFluid += treino.feedback?.coherenceValues[0] ?? 0 // fluid
            totalOrganization += treino.feedback?.coherenceValues[1] ?? 0 // organization
            totalConection += treino.feedback?.coherenceValues[2] ?? 0 // conexion
        }
        
        let avaregeFluid = totalFluid / CGFloat(folder.treinos.count)
        let avaregeOrganization = totalOrganization / CGFloat(folder.treinos.count)
        let avaregeConection = totalConection / CGFloat(folder.treinos.count)
        
        return (avaregeFluid,avaregeOrganization, avaregeConection)
    }
    
    func setObjetiveApresentation(objetiveApresentation: String) -> (phrases: [String], images: [String]) {
         switch objetiveApresentation{
         case "Apresentação de Eventos":
             return (["Informar sobre os detalhes do evento, como data, local e agenda.",
                      "Envolver a audiência na proposta de valor do evento.",
                      "Aumentar a participação e o engajamento dos participantes.",
                      "Comunicar de forma clara e atraente."], ["wand.and.stars", "suitcase.fill", "person.2.fill", "megaphone.fill"])
         case "Apresentação de Vendas":
             return (["Destacar os benefícios do produto ou serviço.",
                      "Despertar o interesse do cliente.",
                      "Incentivar ação, como uma compra ou inscrição.",
                      "Comunicar de forma persuasiva e clara."], ["wand.and.stars", "suitcase.fill", "person.2.fill", "megaphone.fill"])
         case "Apresentação de Pitch":
             return (["Transmitir de forma convincente a ideia de negócio ou projeto.",
                      "Destacar o problema a ser resolvido e a solução proposta.",
                      "Apresentar o potencial de mercado e retorno do investimento.",
                      "Atrair investidores ou parceiros."], ["wand.and.stars", "suitcase.fill", "person.2.fill", "megaphone.fill"])
         case "Apresentação Informativa:":
             return (["Fornecer informações relevantes e úteis sobre um tema específico.",
                      "Garantir compreensão e assimilação do conteúdo pela audiência.",
                      "Utilizar uma linguagem acessível e exemplos claros.",
                      "Transmitir conhecimento de forma objetiva e direta."], ["wand.and.stars", "suitcase.fill", "person.2.fill", "megaphone.fill"])
             
         case "Apresentação Acadêmica":
             return (["Apresentar pesquisa original ou tese.",
                      "Defender argumentos de maneira estruturada e coesa.",
                      "Compartilhar conhecimento dentro do contexto educacional.",
                      "Persuadir e informar o público acadêmico de maneira clara e objetiva."], ["wand.and.stars", "suitcase.fill", "person.2.fill", "megaphone.fill"])
         case "Apresentação de Projetos":
             return (["Comunicar claramente os objetivos e escopo do projeto.",
                      "Apresentar o cronograma e recursos disponíveis.",
                      "Obter apoio da audiência, seja para financiamento ou alinhamento de equipe.",
                      "Garantir entendimento completo dos aspectos técnicos e práticos do projeto.",],["wand.and.stars", "suitcase.fill", "person.2.fill", "megaphone.fill"])
         default:
             return ([], [])
         }
     }
    
    // divide a string para conseguir colocar o texto em bold
    func divideImproveFeedback(videoScript: String, objectiveApresentation: String) {
        self.sendMessage(content: """
                                    Preciso que analise um texto e mande um feedback de forma clara e amigável de pontos para melhorar no script, caso o script esteja bom de o feedback de que está bom, caso tenha pontos bons e ruins, de tanto o feedback positivo quanto o negativo. Não de feedbacks inúteis caso não tenha algum feedback negativo para passar.
                                    Em outro paragrafo analise se a apresentação cumpre com os objetivos do tipo de apresentação desejado. Dê feedbacks de forma clara e amigável também, caso seja negativo fale e de sugestões, caso positivo fale e elogie, caso possua pontos positivos e negativos de feedback dos dois. Não de feedbacks inúteis caso não tenha algum feedback negativo para passar.
                                    Escreva com no máximo 200 caracteres cada um dos parágrafos . Não se refira como script, e sim como apresentação
                                    Escreva os dois feedbacks (analise do texto e relação com o tipo de apresentação) no seguinte formato - call action: feedback
                                    A call action sendo uma frase de ação para o usuário entender o que fazer e o feedback o texto mais explicativo, como no exemplo a seguir:  Utilize técnicas de engajamento: Explore recursos visuais, como gráficos, imagens ou vídeos, para aumentar o engajamento da audiência e tornar a apresentação mais memorável.

                                    Script a analisar: \(videoScript)
                                    
                                    Objetivo da Apresentação: \(objetiveApresentation)
                                    """) { feebacks in
            // separa os dois feedbacks que o chamado da API retorna
            let separetedFeedback = feebacks?.content.components(separatedBy: "\n")
            guard let separetedFeedback = separetedFeedback else { return }
            // separa a call action do contetudo do texto
            var callActions: [String] = []
            var descriptions: [String] = []
            for feedback in separetedFeedback {
                var separeteText = feedback.components(separatedBy: ":")
                callActions.append(separeteText.first ?? "")
                descriptions.append(separeteText.last ?? "")
            }
                
        }
    }
}
