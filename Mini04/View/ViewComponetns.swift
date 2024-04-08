//
//  ViewComponetns.swift
//  Mini04
//
//  Created by João Victor Bernardes Gracês on 26/03/24.
//

import SwiftUI

enum RelativeSizes: CGFloat {
    case width380 = 0.3223
    case height130 = 0.14238
    case height260 = 0.28477
    case height334 = 0.36582
    case height350 = 0.38335
}

struct TimeFeedBackView: View {
    @State var avaregeTime: String
    var wishTime: Double
    var treinos: [TreinoModel]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .frame(width: 350, height: 140)
            .overlay {
                HStack{
                    VStack(alignment: .leading) {
                        Text("\(avaregeTime)")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.black)
                        Text("Tempo médio próximo do desejado. ")
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 135)
                            .foregroundStyle(.black)
                        Spacer()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Tempo desejado - " + String(format: "%.2f", wishTime))
                            .foregroundStyle(.black)
                        HStack {
                            ForEach(treinos.suffix(8)) { treino in // sufix 8 para mostrar os ultimos 8 treinos
                                VStack {
                                    ZStack(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 10, height: 54)
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 10, height: Double(treino.video?.videoTime ?? 0) > Double(wishTime) ? 54 :  treino.video?.videoTime ?? 1)
                                            .foregroundStyle(Double(treino.video?.videoTime ?? 0) > Double(wishTime) ? .red : .blue)
                                        
                                    }
                                    Text("\(treinos.count + 1)")
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        
    }
}

struct TimeFeedBackViewExpand: View {
    @State var avaregeTime: String
    var wishTime: Double
    var treinos: [TreinoModel]
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .frame(width: 350, height: 280)
            .overlay {
                VStack {
                    HStack{
                        VStack(alignment: .leading) {
                            Text("\(avaregeTime)")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.black)
                            Text("Tempo médio próximo do desejado. ")
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: 135)
                                .foregroundStyle(.black)
                            Spacer()
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Tempo desejado - " + String(format: "%.2f", wishTime))
                                .foregroundStyle(.black)
                            HStack {
                                ForEach(treinos.suffix(8)) { treino in // sufix 8 para mostrar os ultimos 8 treinos
                                    VStack {
                                        ZStack(alignment: .bottom) {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 10, height: 54)
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 10, height: Double(treino.video?.videoTime ?? 0) > Double(wishTime) ? 54 :  treino.video?.videoTime ?? 1)
                                                .foregroundStyle(Double(treino.video?.videoTime ?? 0) > Double(wishTime) ? .red : .blue)
                                            
                                        }
                                        Text("\(treinos.count + 1)")
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
                        }
                    }
                    Text("Se manter dentro do tempo proposto é crucial para garantir a clareza e o impacto de sua mensagem!")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.black)
                        .padding(.vertical)
                    Text("Saber aproveita-lo demonstra profissionalismo, mantém o interesse do público e permite uma melhor absorção das informações apresentadas.")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.black)
                        .padding(.vertical)
                }
                .padding()
            }
    }
}

// MARK: - TEMPO MÉDIO DA PASTA
struct TimeFeedbackView: View {
    @ObservedObject var folderVM: FoldersViewModel
    @State private var isExpanded = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .overlay {
                VStack {
                    HStack{
                        VStack(alignment: .leading) {
                            Text("\(folderVM.formatedAvareTime)")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.black)
                            Text("Tempo médio próximo do desejado. ")
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: 135)
                                .foregroundStyle(.black)
                            Spacer()
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Tempo desejado - " + String(format: "%.2f", Double(folderVM.folder.tempoDesejado)))
                                .foregroundStyle(.black)
                            HStack {
                                ForEach(folderVM.folder.treinos.suffix(8)) { treino in // sufix 8 para mostrar os ultimos 8 treinos
                                    VStack {
                                        ZStack(alignment: .bottom) {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 10, height: 54)
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 10, height: Double(treino.video?.videoTime ?? 0) > Double(folderVM.folder.tempoDesejado) ? 54 :  treino.video?.videoTime ?? 1)
                                                .foregroundStyle(Double(treino.video?.videoTime ?? 0) > Double(folderVM.folder.tempoDesejado) ? .red : .blue)
                                            
                                        }
                                        Text("\(folderVM.folder.treinos.count + 1)")
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
                        }
                    }
                    Text("Se manter dentro do tempo proposto é crucial para garantir a clareza e o impacto de sua mensagem!")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.black)
                        .padding(.vertical)
                    Text("Saber aproveita-lo demonstra profissionalismo, mantém o interesse do público e permite uma melhor absorção das informações apresentadas.")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.black)
                        .padding(.vertical)
                }
                .padding()
            }
            .frame(width: 350, height: isExpanded ? 422 : 272)
            .onTapGesture {
                withAnimation(.spring(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
    }
}

// MARK: - PALAVRAS REPETIDAS DA PASTA
struct WordRepetitionView: View {
    @ObservedObject var folderVM: FoldersViewModel
    @State private var isExpanded = false
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    
    var body: some View {
        let allRepeatedWords = folderVM.folder.treinos.flatMap { $0.feedback?.repeatedWords ?? [] }.map { $0.word }
        let uniqueWords = Set(allRepeatedWords)
        
        RoundedRectangle(cornerRadius: 16)
            .overlay {
                HStack {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            // titulo e seta
                            HStack {
                                // Titulo e subtitulo
                                let palavra = uniqueWords.count > 1 ? "Palavras" : "Palavra"
                                Text("\(uniqueWords.count) \(palavra)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.black)
                                    .font(.title2)
                                    .padding(.trailing, 4) // Espaçamento entre o texto e a seta
                            }
                            Text("Repetidas em excesso")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        
                        // Lista de palavras repetidas
                        HStack {
                            ForEach(uniqueWords.sorted(), id: \.self) { word in
                                Text(word)
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundStyle(.white)
                                    }
                            }
                        }
                        
                        // Conteúdo inferior condicionalmente visível
                        if isExpanded {
                            HStack {
                                ForEach(uniqueWords.sorted(), id: \.self) { word in
                                    Text(word)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background {
                                            RoundedRectangle(cornerRadius: 6)
                                                .foregroundStyle(.black.opacity(0.7))
                                        }
                                }
                            }
                            .padding(.vertical, 20)
                        }
                        Spacer() // vstack
                    }
                    .padding()
                    
                    Spacer() // hstack
                }
            }
            .frame(width: widthFrame * RelativeSizes.width380.rawValue, height: isExpanded ? heightFrame *  RelativeSizes.height334.rawValue : heightFrame * RelativeSizes.height130.rawValue)
            .onHover { over in
                withAnimation(.spring(duration: 0.3)) {
                    isExpanded = over
                }
            }
    }
}

struct ExpandableView: View {
    @Namespace private var namespace // usada para criar animacoes mais suaves
    @State private var show: Bool = false
    
    var thumbnail: ThumbnailView
    var expanded: ExpandedView
    
    var thumbnailViewBackgroundColor: Color = .gray.opacity(0.8)
    var expandedViewBackgroundColor: Color = .gray
    
    var thumbnailViewCornerRadius: CGFloat = 20
    var expandedViewCornerRadius: CGFloat = 20
    
    var body: some View {
        ZStack {
            if !show {
                thumbnailView()
            } else {
                expandedView()
            }
        }
        .onTapGesture() {
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                show.toggle()
                
            }
        }
    }
    
    @ViewBuilder
    private func thumbnailView() -> some View {
        ZStack {
            thumbnail
                .matchedGeometryEffect(id: "view", in: namespace)
        }
        .background(thumbnailViewBackgroundColor.matchedGeometryEffect(id: "background", in: namespace))
        .mask {
            RoundedRectangle(cornerRadius: thumbnailViewCornerRadius, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        }
    }
    
    @ViewBuilder
    private func expandedView() -> some View {
        ZStack {
            expanded
                .matchedGeometryEffect(id: "view", in: namespace)
        }
        .background(expandedViewBackgroundColor.matchedGeometryEffect(id: "background", in: namespace))
        .mask {
            RoundedRectangle(cornerRadius: expandedViewCornerRadius, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        }
    }
}

struct ThumbnailView: View {
    var id: UUID = UUID()
    @ViewBuilder var content: any View
    var body: some View {
        ZStack{
            AnyView(content)
        }
    }
}

struct ExpandedView: View {
    var id: UUID = UUID()
    @ViewBuilder var content: any View
    var body: some View {
        ZStack{
            AnyView(content)
        }
    }
}

struct CircularProgress: View {
    var sizeCircle: CGFloat
    var progress: CGFloat
    var totalProgress: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.72), style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
            
            Circle()
                .trim(from: 0.0, to:
                        withAnimation {
                    CGFloat(progress)/totalProgress
                })
                .stroke(.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: "timer")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.black)
                .bold()
                .frame(maxWidth: sizeCircle * 0.3)
        }
        .frame(maxWidth: sizeCircle)
    }
}

struct TimeCircularFeedback: View {
    var title: String
    var subtitle: String
    var objetiveTime: Int
    var bodyText: String
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    var progress: CGFloat
    var totalProgress: CGFloat
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .overlay {
                    HStack(alignment: .top) {
                        CircularProgress(sizeCircle: proxy.size.height * 0.7, progress: progress, totalProgress: totalProgress)
                            .padding()
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(title)
                                        .font(.title2)
                                        .bold()
                                        .foregroundStyle(.black)
                                        .padding(.top, 10)
                                    Text(subtitle)
                                        .font(.footnote)
                                        .foregroundStyle(.black)
                                        .padding(.bottom, 10)
                                }
                                Spacer()
                                Text("Objetivo: \(objetiveTime) min")
                                    .foregroundStyle(.black)
                                    .opacity(0.7)
                                    .padding(.top, 10)
                            }
                            Text(bodyText)
                            // .font(.caption)
                                .multilineTextAlignment(.leading)
                                .lineLimit(.bitWidth)
                                .foregroundStyle(.black)
                                .opacity(0.6)
                        }
                    }
                    .padding(.horizontal)
                }
        }
        .frame(width: widthFrame, height: heightFrame) // TODO: deixar responsivo
    }
}

struct CohesionFeedback: View {
    var bodyText: String = "Sua apresentação fluiu de forma natural, com uma organização lógica e transições suaves entre os tópicos apresentados."
    var titleFeedback01: String = "Fluidez do Discurso"
    var titleFeedback02: String = "Organização Lógica"
    var titleFeedback03: String = "Conexão entre Tópicos"
    var fluidProgress: CGFloat
    var organizationProgress: CGFloat
    var connectionProgress: CGFloat
    var footnoteText: String = "Isso mantem o público envolvido e facilita a compreensão das ideias apresentadas. "
    var feedbackFootNote: String = "Ótimo trabalho!"
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16)
                .overlay {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Image(systemName: "rectangle.inset.filled.and.person.filled")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.black)
                                .bold()
                                .frame(maxWidth: proxy.size.width * 0.08)
                            Text("Apresentação Coesa!")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.black)
                                .frame(maxWidth: proxy.size.width * 0.04)
                        }
                        Text(bodyText)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .frame(maxWidth: 306)
                            .padding(.top, 2)
                        
                        BarProgress_Component(title: titleFeedback01, progress: fluidProgress, maxProgress: 238)
                            .padding(.top, 10)
                        Group {
                            BarProgress_Component(title: titleFeedback02, progress: organizationProgress, maxProgress: 238)
                            BarProgress_Component(title: titleFeedback03, progress: connectionProgress, maxProgress: 238)
                        }
                        .padding(.top, 5)
                        Text(footnoteText)
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .padding(.top, 10)
                        
                        Spacer()
                        Text(feedbackFootNote)
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .bold()
                    }
                    .padding()
                }
        }
        .frame(width: widthFrame, height: heightFrame) // TODO: deixar responsivo
    }
}

struct BarProgress_Component: View {
    var title: String
    var progress: CGFloat
    var maxProgress: CGFloat
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.black)
                .opacity(0.5)
            HStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(maxWidth: maxProgress)
                        .frame(height: 14)
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.black)
                        .frame(maxWidth: (progress/100) * maxProgress)
                        .frame(height: 14)
                }
                Text("\(progress.formatted()) %")
                    .font(.caption)
                    .foregroundStyle(.black)
            }
        }
    }
}

struct ImproveApresentationView: View {
    var title: String = "Como melhorar sua apresentação:"
    var subTitle: String = "De acordo com os seus feedbacks"
    var callAction: String = "Reforce a chamada à ação:"
    var bodyText: String = " Certifique-se de que a chamada à ação seja clara, específica e irresistível."
    @State var isExtended: Bool = false
    var allCallActions: [String] = ["Reforce a chamada à ação:", "Cuidado com a repetição excessiva das mesmas palavras:", "Refine o timing da apresentação:", "Utilize técnicas de engajamento:"]
    var allBodyText: [String] = [" Certifique-se de que a chamada à ação seja clara, específica e irresistível.", " Utilize sinônimos ou formas diferentes de expressar ideias sem perder a clareza.", " Embora o tempo médio esteja próximo do desejado, considere ajustes pontuais para garantir que cada parte da apresentação receba a atenção adequada", " Explore recursos visuais, como gráficos, imagens ou vídeos, para aumentar o engajamento da audiência e tornar a apresentação mais memorável."]
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
                .overlay {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.title2)
                            .foregroundStyle(.black)
                            .bold()
                        Text(subTitle)
                            .font(.footnote)
                            .foregroundStyle(.black)
                            .padding(.bottom, 10)
                        if !isExtended {
                            ImproveTextFeedbackComponet(callAction: callAction, bodyText: bodyText)
                                .padding(.top, 5)
                            
                        } else {
                            ForEach(0..<allBodyText.count, id: \.self) { index in
                                ImproveTextFeedbackComponet(callAction: allCallActions[index], bodyText: allBodyText[index])
                                    .padding(.top, 5)
                            }
                        }
                    }
                    .padding()
                }
        }.onHover { over in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isExtended = over
            }
        }
        .frame(maxWidth: widthFrame * RelativeSizes.width380.rawValue, maxHeight: isExtended ? heightFrame * RelativeSizes.height334.rawValue : heightFrame * RelativeSizes.height130.rawValue)
    }
}

// Textos do Como melhorar sua apresentação
struct ImproveTextFeedbackComponet: View {
    var callAction: String
    var bodyText: String
    var body: some View {
        HStack(alignment: .top) {
            //                            Image(systemName: "exclamationmark.triangle.fill")
            //                                .resizable()
            //                                .scaledToFit()
            //                                .frame(maxWidth: proxy.size.width * 0.03)
            //                                .padding(.top, 3)
            Text("\(callAction)" + bodyText)
                .font(.callout)
                .foregroundStyle(.black)
        }
    }
}

struct ObjectiveApresentationView: View {
    @State var isExtended: Bool = false
    var title: String = "Objetivos da Apresentação"
    var subTitle: String  = "De acordo com o tipo de apresentação informado"
    var allImages: [String] = ["wand.and.stars", "suitcase.fill", "person.2.fill", "megaphone.fill"]
    var allObjText: [String] = ["Destacar os benefícios do produto ou serviço.", "Incentivar ação, como uma compra ou inscrição.", "Despertar o interesse do público (clientes). ", "Comunicar de forma persuasiva e clara."]
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16)
    
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "scope")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.black)
                                    .bold()
                                    .frame(maxWidth: proxy.size.width * 0.06)
                                Text(title)
                                    .font(.title2)
                                    .foregroundStyle(.black)
                                    .bold()
                            }
                            Text(subTitle)
                                .font(.footnote)
                                .foregroundStyle(.black)
                                .padding(.bottom, 10)
                            if !isExtended {
                                ObjectiveApresentationTopicsComponent(widthSize: proxy.size.width * 0.8, heightSize: proxy.size.height * 0.07, title: allObjText[0], imageName:  allImages[0])
                            } else {
                                ForEach(0..<allObjText.count, id: \.self) { index in
                                    ObjectiveApresentationTopicsComponent(widthSize: proxy.size.width * 0.8, heightSize: proxy.size.height * 0.07, title: allObjText[index], imageName:  allImages[index])
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                    .padding(.leading, 5)
                }
        }.onHover { over in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isExtended = over
            }
        }
        .frame(maxWidth: widthFrame * RelativeSizes.width380.rawValue, maxHeight: isExtended ? heightFrame * RelativeSizes.height260.rawValue : heightFrame * RelativeSizes.height130.rawValue)
    }
}

struct ObjectiveApresentationTopicsComponent: View {
    var widthSize: CGFloat
    var heightSize: CGFloat
    var title: String
    var imageName: String
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.black)
                    .bold()
                    .frame(maxWidth: widthSize * 0.04)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.black)
            }
            .padding(5)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
            //        .frame(maxWidth: widthSize, maxHeight: heightSize)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.gray)
                .scaledToFill()
            ProgressView("Criando treino...")
                .progressViewStyle(.circular)
        }
    }
}

struct AvaregeTimeFeedbackView: View {
    @State var avaregeTime: String
    var wishTime: Double
    var treinos: [TreinoModel]
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    
    var body: some View {
        
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16)
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(avaregeTime) Tempo médio")
                                .font(.system(size: proxy.size.width * 0.0723))
                                .bold()
                                .foregroundStyle(.black)
                            Text("próximo do desejado. ")
                                .font(.system(size: proxy.size.width * 0.0553))
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.black)
                                .opacity(0.6)
                            Text("Tempo objetivo \(wishTime.formatted()) minutos")
                                .font(.system(size: proxy.size.width * 0.0468))
                               // .font(.footnote)
                                .foregroundStyle(.black)
                                .opacity(0.5)
                                .padding(.top)
                            HStack {
                                if treinos.isEmpty {
                                    Spacer()
                                    Text("Nenhum treino criado")
                                        .font(.title3)
                                        .foregroundStyle(.black)
                                        .padding()
                                    Spacer()
                                } else {
                                    // mostrar apenas 8 treinos graficos
                                    ForEach(0..<(treinos.count < 8 ? treinos.count : 8), id: \.self) { index in
                                        VStack {
                                            ZStack(alignment: .bottom) {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(maxWidth: 14, maxHeight: proxy.size.height * 0.45)
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(width: 14, height: Double(treinos[index].video?.videoTime ?? 0) > Double(wishTime) ? proxy.size.height * 0.45 :  treinos[index].video?.videoTime ?? 1)
                                                    .foregroundStyle(Double(treinos[index].video?.videoTime ?? 0) > Double(wishTime) ? .red : .blue)
                                            }
                                            Text("T \(treinos.count - index)")
                                                .font(.footnote)
                                                .foregroundStyle(.black)
                                                .opacity(0.5)
                                        }
                                        .padding(.top, 5)
                                    }
                            }
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
            }
        }
        .frame(maxWidth: widthFrame * 0.21, maxHeight: heightFrame * 0.296)
    }
}



#Preview {
    TimeCircularFeedback(title: "5:37", subtitle: "Tempo total", objetiveTime: 6, bodyText: "Embora o tempo médio esteja próximo do desejado, considere ajustes pontuais para garantir que cada parte da apresentação receba a atenção adequada.", widthFrame: 442, heightFrame: 350, progress: 80, totalProgress: 100)
}

//#Preview {
//    TimeFeedBackView(avaregeTime: "10:", wishTime: 8, treinos: [])
//}

//#Preview {
//    CohesionFeedback(fluidProgress: 50, organizationProgress: 90, connectionProgress: 85)
//}
//
//#Preview {
//    AvaregeTimeFeedbackView(avaregeTime: "00:66", wishTime: 10, treinos: [TreinoModel(),TreinoModel(),TreinoModel(), TreinoModel()], widthFrame: 1179.0, heightFrame: 913)
//}

