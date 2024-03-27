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
                                    Text("T\(treinos.count + 1)")
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

#Preview {
    TimeFeedBackView(avaregeTime: "10:", wishTime: 8, treinos: [])
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
