//
//  ViewComponetns.swift
//  Mini04
//
//  Created by João Victor Bernardes Gracês on 26/03/24.
//

import SwiftUI

struct TimeFeedBackView: View {
   @State var avaregeTime: String
    var wishTime: Double
    var treinos: [TreinoModel]
    
    var body: some View {
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
                                    Text("T\(treinos.count + 1)")
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                    }
                }
                .padding()
                .clipShape(        RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
            }
        
    }
}

struct TimeFeedBackViewExpand: View {
    @State var avaregeTime: String
     var wishTime: Double
     var treinos: [TreinoModel]
    var body: some View {
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
                                        Text("T\(treinos.count + 1)")
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
                .clipShape(        RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
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

struct TreinoVisualComponent: View {
    var treinoName: String
    var treinoDate: String
    var treinoDuration: String
    var body: some View {
        //GeometryReader { geo in
                RoundedRectangle(cornerRadius: 16)
                .frame(minWidth: 584, maxWidth: .infinity)
                .frame(minHeight: 50, maxHeight: 74)
//                .frame(width: 584, height: 50)
                .overlay {
                HStack(alignment: .center) {
                    Spacer()
                    Image(systemName:"video.badge.waveform.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundStyle(.black)
                    Spacer()
                    Text(treinoName)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.black)
                    Spacer()
                    Text(treinoDate)
                        .font(.title)
                        .foregroundStyle(.black)
                        .opacity(0.8)
                    Spacer()
                    Text(treinoDuration)
                        .font(.title)
                        .foregroundStyle(.black)
                        .opacity(0.8)
                    Spacer()
                }
            }
      //  }
    //    frame(maxWidth: .infinity)
    }
}



//#Preview {
//    TreinoVisualComponent(treinoName: "Trenio 12", treinoDate: "12 de out. de 2023", treinoDuration: "06:66")
//}

//#Preview {
//    CircularProgress(padding: 100, progress: 90)
//}

#Preview {
    ObjetiveFeedBackView()
    }


struct CircularProgress: View {
    var sizeCircle: CGFloat
    @State var progress: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.72), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                
            Circle()
                .trim(from: 0.0, to: CGFloat(progress)/100)
                .stroke(.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(-90))

            Text("\(progress.formatted())%")
                .font(.title)
                .foregroundStyle(.black)
        }
        .frame(maxWidth: sizeCircle)
    }
}

struct ObjetiveFeedBackView: View {
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 16, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .overlay {
                    HStack(alignment: .top) {
                        CircularProgress(sizeCircle: proxy.size.height * 0.7, progress: 80)
                            .padding()
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "scope")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.black)
                                    .bold()
                                    .frame(maxWidth: 25)
                                Text("Objetivo Alcançado")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.black)
                                    .lineLimit(0)
                            }
                            .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                            Text("A apresentação atual cumpre efetivamente o objetivo de transmitir informações sobre o tópico em questão. Os conceitos são explicados de forma clara e organizada, facilitando a compreensão por parte do público-alvo.")
                            // .font(.caption)
                                .multilineTextAlignment(.leading)
                                .lineLimit(.bitWidth)
                                .foregroundStyle(.black)
                                .opacity(0.6)
                        }
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.black)
                            .frame(maxWidth: 20)
                    }
                    .padding(.horizontal)
                }
        }
    }
}
