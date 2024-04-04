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
    func createNewTraining(videoURL: URL, videoScript: String, videoTime: TimeInterval, videoTopics: [String], topicsDuration: [TimeInterval]) {
        self.showLoadingView = true
        guard let modelContext = modelContext else { return }
        DispatchQueue.main.async {
            self.processFeedbacks(videoScript: videoScript) { [self] feedback in
                let newTraining = TreinoModel(name: "Treino \(folder.treinos.count + 1)",
                                              video: VideoModel(videoURL: videoURL,
                                                                script: videoScript,
                                                                videoTime: videoTime,
                                                                videoTopics: videoTopics,
                                                                topicsDuration: topicsDuration),
                                              feedback: feedback)
                
                do {
                    folder.treinos.append(newTraining)
                    modelContext.insert(newTraining)
                    try modelContext.save()
                    
                } catch {
                    print("Não conseguiu criar e salvar o treino. \(error)")
                }
            }
            self.showLoadingView = false
        }
    }
    
    // MARK: - FEEDBACKS
    func processFeedbacks(videoScript: String, completion: @escaping (FeedbackModel) -> Void) {
        let repeatedWords = filterRepeatedWordsOverFiveTimes(videoScript: videoScript)
        var repeatedWordFeedbacks: [RepeatedWordsModel] = []
        let group = DispatchGroup()
        
        for word in repeatedWords {
            globalGroup.enter()
            fetchSynonyms(for: word) { synonymsModel in
                if let synonymsModel = synonymsModel {
                    // Formatando a palavra para a primeira maiúscula sempre
                    let formattedWord = word.prefix(1).uppercased() + word.lowercased().dropFirst()
                    // Criando uma instância de RepeatedWordsModel com a palavra formatada
                    let repeatedWordModel = RepeatedWordsModel(word: formattedWord, numSynonyms: synonymsModel.numSynonyms, numContexts: synonymsModel.numContexts, synonymContexts: synonymsModel.synonymContexts)
                    repeatedWordFeedbacks.append(repeatedWordModel)
                }
                self.globalGroup.leave()
            }
        }
        globalGroup.notify(queue: .main) {
            //        self.sendMessage(content: """
            //                                              Considerando que as 3 principais características de uma apresentação coesa são: Fluidez do Discurso, Organização Lógica e Conexão entre Ideias. Me dê somente as porcentagens (sem texto explicativo, apenas as porcentagens) de cada  parâmetro (considerando que cada um vale 100% individualmente) analise a seguinte apresentação: Você sabia que 63.3 bilhões de dólares são perdidos anualmente por doenças ocupacionais como o burnout? É um problema tão grande atualmente que, no Japão, existe até uma palavra específica para descrever morte por estresse intenso no trabalho: Karoshi. Pensando nisso,  nós desenvolvemos o Be Cool!, uma solução digital que busca ajudar na organização das suas tarefas profissionais de uma maneira balanceada.
            //
            //                                              No Be Cool você cria uma meta de trabalho e, de acordo com cada tarefa planejada, sugerimos um tempo especial para suas atividades de lazer, porque ter esse tipo de equilíbrio na sua rotina é uma parte essencial para uma vida mais saudável.
            //
            //                                              Após a criação da sua meta de trabalho o Bico, nosso mascote, te ajuda a visualizar em quais atividades focar no momento - desincentivando a procrastinação ou o trabalho excessivo, já que nenhum extremo é saudável a longo prazo.
            //
            //                                              Quando você completa sua meta, o Be Cool salva essa memória na sua aba de conquistas e te convida a fazer uma reflexão sobre seu desempenho. Para pessoas que tem sintomas de burnout, é muito importante tirar um momento para reconhecer suas vitórias e analisar seu humor, o que pode ajudar a identificar mais cedo os sinais de alerta dessa síndrome.
            //
            //                                              O mais legal do Be Cool é que sua aplicação não fica só restringida ao meio profissional, já que, de acordo com os nossos estudos, ele também pode e deve ser usado durante a carreira acadêmica que, como qualquer outra, demanda um cuidado especial!
            //
            //                                              Pensando em todo potêncial do app, estamos trabalhando em melhorias para deixar a experiência ainda melhor! Em breve chegarão novas funcionalidades com um deisgn totalmente revisado e ainda mais intuitivo.
            //
            //                                              Por isso, baixe agora e fique de olho em nossas atualizações! Use o Be Cool e viva uma vida mais balanceada.
            //                                            """) { coherenceBrute in
            let retornoGPT:Message = Message(role: "assistant", content: "Fluidez do Discurso: 90%\nOrganização Lógica: 95%\nConexão entre Ideias: 100%")
            let coherence = self.convertPorcentageCohesionFeedback(message: retornoGPT)
            let feedback = FeedbackModel(coherence: 0, repeatedWords: repeatedWordFeedbacks, coherenceValues: coherence)
            completion(feedback)
        }
        //    } // chaves do completion do send message
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

    // filtra palavras e separa as repetidas 5 vezes
    func filterRepeatedWordsOverFiveTimes(videoScript: String) -> [String] {
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
        let repeatedWords_5 = repeatedWords.filter { $0.value >= 5 }.map { $0.key }
        
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
        return CGFloat(videoTime) / CGFloat(folder.tempoDesejado) * 54
    }
    
    // tranforma o retorno do chatGTP em porcentagem par montar os graficos de feedback
    func convertPorcentageCohesionFeedback(message: Message?) -> [CGFloat] {
        // porcentagens do feecback de coesa
        var porcentages: [CGFloat] = []
        if message?.role == "assistant" {
            // Separando o retorno da API em uma array para pegar o valor de cada %
            guard let separeteValues = message?.content.split(separator: "\n")
            else { print("Erro no result GPT - Joao sabe onde")
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
}
