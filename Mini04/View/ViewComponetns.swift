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

enum RelativeFontSizes: CGFloat {
    case width380size13 = 0.034210526315789476
    case width380size17 = 0.04473684210526316
    case width380size22 = 0.05789473684210526
    case width248size13 = 0.05241935483870968
    case width248size17 = 0.06854838709677419
    case width248size22 = 0.08870967741935484

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
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(folderVM.folder.formattedGoalTime())") // Formatando o tempo desejado
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
                            Text("Tempo desejado - \(folderVM.folder.formattedGoalTime())") // Formatando o tempo desejado
                                .foregroundStyle(.black)
                            HStack {
                                ForEach(folderVM.folder.treinos.suffix(8)) { treino in // sufix 8 para mostrar os ultimos 8 treinos
                                    VStack {
                                        ZStack(alignment: .bottom) {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 10, height: 54)
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 10, height: Double(treino.video?.videoTime ?? 0) > Double(folderVM.folder.tempoDesejado) ? 54 :  Double(treino.video?.videoTime ?? 0))
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
            .stroke(Color("light_Blue"), lineWidth: 2)
            .fill(.white)
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
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.isExpanded.toggle()
                }
            }
            .frame(width: widthFrame * RelativeSizes.width380.rawValue, height: isExpanded ? heightFrame *  RelativeSizes.height334.rawValue : heightFrame * RelativeSizes.height130.rawValue)
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
                .stroke(.gray.opacity(0.3), style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
            Circle()
                .trim(from: 0.0, to:
                        withAnimation {
                    CGFloat(progress)/totalProgress
                })
                .stroke(Color("light_Orange"), style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: "timer")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("light_Orange"))
                .bold()
                .frame(maxWidth: sizeCircle * 0.3)
        }
        .frame(maxWidth: sizeCircle)
    }
}

struct TimeCircularFeedback: View {
    var title: String
    var subtitle: String
    var objetiveTime: String
    var bodyText: String
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    var progress: CGFloat
    var totalProgress: CGFloat
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .stroke(Color("light_Orange"), lineWidth: 2)
                .fill(Color("light_White"))
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
                                Text("Objetivo: \(objetiveTime)")
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
                .stroke(Color("light_Orange"), lineWidth: 2)
                .fill(Color("light_White"))
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
                        
                        BarProgress_Component(title: titleFeedback01, progress: fluidProgress, maxProgress: 238, lightColor: "light_Orange", boldColor: "light_Orange")
                            .padding(.top, 10)
                        Group {
                            BarProgress_Component(title: titleFeedback02, progress: organizationProgress, maxProgress: 238, lightColor: "light_Orange", boldColor: "light_Orange")
                            BarProgress_Component(title: titleFeedback03, progress: connectionProgress, maxProgress: 238, lightColor: "light_Orange", boldColor: "light_Orange")
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

struct CohesionExtendView: View {
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
    @State var isExtended: Bool = false
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("light_Blue"), lineWidth: 2)
                .fill(.white)
                .overlay {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Image(systemName: "rectangle.inset.filled.and.person.filled")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color("light_DarkerGreen"))
                                .bold()
                                .frame(maxWidth: widthFrame * 0.03)
                            Text("Apresentação Coesa!")
                                .font(.system(size: proxy.size.width * 0.044))
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
                            .font(.system(size: proxy.size.width * RelativeFontSizes.width380size13.rawValue))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .frame(maxWidth: 306)
                            .padding(.top, 2)
                        if isExtended {
                            BarProgress_Component(title: titleFeedback01, progress: fluidProgress, maxProgress: 238, lightColor: "light_Blue", boldColor: "light_DarkerGreen")
                                .padding(.top, 10)
                            Group {
                                BarProgress_Component(title: titleFeedback02, progress: organizationProgress, maxProgress: 238, lightColor: "light_Blue", boldColor: "light_DarkerGreen")
                                BarProgress_Component(title: titleFeedback03, progress: connectionProgress, maxProgress: 238, lightColor: "light_Blue", boldColor: "light_DarkerGreen")
                            }
                            .padding(.top, 5)
                            Text(footnoteText)
                                .font(.system(size: proxy.size.width * RelativeFontSizes.width380size13.rawValue))
                                .foregroundStyle(.black)
                                .opacity(0.5)
                                .padding(.top, 10)
                            
                            Spacer()
                            Text(feedbackFootNote)
                                .font(.system(size: proxy.size.width * RelativeFontSizes.width380size13.rawValue))
                                .foregroundStyle(Color("light_DarkerGreen"))
                                .bold()
                        }
                    }
                    .padding()
                }
        }
        .frame(maxWidth: widthFrame * RelativeSizes.width380.rawValue, maxHeight: isExtended ? heightFrame * RelativeSizes.height350.rawValue : heightFrame * RelativeSizes.height130.rawValue)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isExtended.toggle()
            }
        }
    }
}

struct BarProgress_Component: View {
    var title: String
    var progress: CGFloat
    var maxProgress: CGFloat
    var lightColor: String
    var boldColor: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color(lightColor))
            //  .opacity(0.5)
            HStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(maxWidth: maxProgress)
                        .frame(height: 14)
                        .foregroundStyle(.gray)
                        .opacity(0.3)
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color(lightColor))
                        .frame(maxWidth: (progress/100) * maxProgress)
                        .frame(height: 14)
                }
                Text("\(progress.formatted()) %")
                    .font(.caption)
                    .foregroundStyle(Color(lightColor))
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
                .stroke(Color("light_Blue"), lineWidth: 2)
                .fill(.white)
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.system(size: proxy.size.width * RelativeFontSizes.width380size17.rawValue))
                                .foregroundStyle(Color("light_DarkerGreen"))
                                .bold()
                            Text(subTitle)
                                .font(.system(size: proxy.size.width * RelativeFontSizes.width380size13.rawValue))
                                .foregroundStyle(.black)
                                .padding(.bottom, 10)
                            if !isExtended {
                                ImproveTextFeedbackComponet(callAction: callAction, bodyText: bodyText, widthSize: proxy.size.width)
                                    .padding(.top, 5)
                                
                            } else {
                                ForEach(0..<allBodyText.count, id: \.self) { index in
                                    ImproveTextFeedbackComponet(callAction: allCallActions[index], bodyText: allBodyText[index], widthSize: proxy.size.width)
                                        .padding(.top, 5)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
        }.onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isExtended.toggle()
            }
        }
        .frame(maxWidth: widthFrame * RelativeSizes.width380.rawValue, maxHeight: isExtended ? heightFrame * RelativeSizes.height334.rawValue : heightFrame * RelativeSizes.height130.rawValue)
    }
}

// Textos do Como melhorar sua apresentação
struct ImproveTextFeedbackComponet: View {
    var callAction: String
    var bodyText: String
    @State var widthSize: CGFloat
    var body: some View {
        HStack(alignment: .top) {
            Text(Image(systemName: "exclamationmark.triangle.fill"))
                .font(.system(size: widthSize * RelativeFontSizes.width380size13.rawValue))
                .foregroundStyle(Color("light_DarkerGreen")) +
            Text(callAction)
                .font(.system(size: widthSize * RelativeFontSizes.width380size13.rawValue))
                .foregroundStyle(Color("light_DarkerGreen"))
                .bold() +
            Text(bodyText)
                .font(.system(size: widthSize * RelativeFontSizes.width380size13.rawValue))
                .foregroundStyle(Color("light_DarkerGreen"))
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
                .stroke(Color("light_Blue"), lineWidth: 2)
                .fill(.white)
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "scope")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color("light_DarkerGreen"))
                                    .bold()
                                    .frame(maxWidth: proxy.size.width * 0.06)
                                Text(title)
                                    .font(.system(size: proxy.size.width * RelativeFontSizes.width380size17.rawValue))
                                    .foregroundStyle(Color("light_DarkerGreen"))
                                    .bold()
                            }
                            Text(subTitle)
                                .font(.system(size: proxy.size.width * RelativeFontSizes.width380size13.rawValue))
                                .foregroundStyle(.black)
                                .padding(.bottom, 10)
                            if !isExtended {
                                ObjectiveApresentationTopicsComponent(widthSize: proxy.size.width * 0.8, heightSize: proxy.size.height * 0.07, title: allObjText[0], imageName:  allImages[0])
                            } else {
                                ForEach(0..<allObjText.count, id: \.self) { index in
                                    ObjectiveApresentationTopicsComponent(widthSize: proxy.size.width * 0.8, heightSize: proxy.size.height * 0.07, title: allObjText[index], imageName:  allImages[index])
                                }
                                Text("Ao definir objetivos, você molda a apresentação de forma a atingir os resultados desejados. Isso ajuda a manter o foco e a coesão, garantindo que sua mensagem seja transmitida de maneira eficaz e envolvente para o público.")
                                    .font(.system(size: proxy.size.width * RelativeFontSizes.width380size13.rawValue))
                                    .foregroundStyle(.black)
                                    .opacity(0.5)
                                    .padding(.top, 24)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                    .padding(.leading, 5)
                }
        }.onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isExtended.toggle()
            }
        }
        .frame(maxWidth: widthFrame * RelativeSizes.width380.rawValue, maxHeight: isExtended ? heightFrame * RelativeSizes.height350.rawValue : heightFrame * RelativeSizes.height130.rawValue)
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
                    .foregroundStyle(Color("light_DarkerGreen"))
                    .bold()
                    .frame(maxWidth: widthSize * 0.05)
                Text(title)
                    .font(.system(size: widthSize * RelativeFontSizes.width380size17.rawValue))
                    .foregroundStyle(Color("light_DarkerGreen"))
            }
            .padding(5)
            .padding(.leading, 5)
            .background(Color("light_LighterBlue"))
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
    var wishTimeText: String
    var wishTime: Int
    var treinos: [TreinoModel]
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    @State var isExtended: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("light_Blue"), lineWidth: 2)
                .fill(.white)
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
                            Text("Tempo objetivo \(wishTimeText)") // Formatando o tempo desejado
                                .font(.system(size: proxy.size.width * 0.0468))
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
                                        AvaregeFeedbackGrafics(
                                            widthFrame: 14,
                                            heightFrame: proxy.size.height * 0.45,
                                            titleText: String(treinos.count - index),
                                            porcentage: CGFloat(treinos[index].video?.videoTime ?? 0) > CGFloat(wishTime) ? proxy.size.height * 0.45 : CGFloat(treinos[index].video?.videoTime ?? 1) / CGFloat(wishTime) * 100
                                        )
                                            .padding(.top, 5)
                                    }
                                }
                            }
                            if isExtended {

                                VStack(alignment: .leading) {
                                    HStack {
                                        Rectangle()
                                            .frame(maxWidth: widthFrame * 0.21 * 0.04, maxHeight: widthFrame * 0.21 * 0.04)
                                            .foregroundStyle(Color("light_Blue"))
                                        Text("Dentro do desejado")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Color("light_Blue"))
                                    }
                                    HStack {
                                        Rectangle()
                                            .frame(maxWidth: widthFrame * 0.21 * 0.04, maxHeight: widthFrame * 0.21 * 0.04)
                                            .foregroundStyle(Color("light_DarkerGreen"))
                                        Text("Fora do desejado")
                                            .font(.system(size: 10))
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(Color("light_DarkerGreen"))
                                    }
                                }
                                .padding(.top, 5)
                                Text("Se manter dentro do tempo proposto é crucial para garantir a clareza e o impacto de sua mensagem! ")
                                    .font(.system(size: proxy.size.width * 0.0553))
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.black)
                                    .opacity(0.6)
                                    .padding(.top, 5)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isExtended.toggle()
            }
        }
        .frame(maxWidth: widthFrame * 0.21, maxHeight: isExtended ? .calculateHeightPercentageFullScreen(componentHeight: 699, heightScreenSize: heightFrame) : heightFrame * 0.296 )
    }
}



struct AvaregeFeedbackGrafics: View {
    var widthFrame: CGFloat
    var heightFrame: CGFloat
    var titleText: String
    var porcentage: CGFloat
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(maxWidth: widthFrame, maxHeight: heightFrame)
                    .foregroundStyle(.gray)
                    .opacity(0.3)
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 14, height: porcentage )
                    .foregroundStyle(porcentage > 100 ? Color("light_DarkerGreen") : Color("light_Blue"))
            }
            Text("T \(titleText)")
                .font(.footnote)
                .foregroundStyle(.black)
                .opacity(0.5)
        }
    }
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

