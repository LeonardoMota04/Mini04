//
//  teste.swift
//  Mini04
//
//  Created by luis fontinelles on 29/03/24.
//

import SwiftUI

struct teste: View {
    @State private var verticalPosition: CGFloat = 0
    @State private var isShowingModal = false
    @State var pickedNumber: Int?
    @Namespace var namespace

    var body: some View {
        VStack {
            if pickedNumber == nil {
                VStack(spacing: 15) {
                    ForEach(0..<3) { number in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 300, height: 50)
                                .foregroundStyle(.blue)
                            
                            Button("Hello world \(number)") {
                                withAnimation {
                                    pickedNumber = number
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(width: 300, height: 30, alignment: .center)
                        }
                        
                    }
                }
            } else {
                ForEach(0..<3) { number in
                    if pickedNumber == number {
                        ZStack {
                            customModal(animation: namespace, isShowingModal: $isShowingModal, pickedNumber: $pickedNumber)
                        }
                    }
                }
            }
        }
    }
}

struct customModal: View {
    var animation: Namespace.ID
    @Binding var isShowingModal: Bool
    @Binding var pickedNumber: Int?

    var body: some View {
        ScrollView {
            Button("Fechar") {
                withAnimation {
                    isShowingModal.toggle()
                    pickedNumber = nil
                }
            }
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue)
                    .ignoresSafeArea(.all)

                VStack {
                    Spacer()

                    ScrollViewReader { proxy in
                        ScrollView {
                            ForEach(1...100, id: \.self) { index in
                                Text("Slide me down to make me disappear...")
                                    .font(.largeTitle)
                                    .id(index)
                                    .matchedGeometryEffect(id: index, in: animation)
                            }

                        }
                    }

                    Spacer()
                }
            }
        }
        .frame(maxWidth: 400, maxHeight: .infinity)
        .padding()
    }
}

struct teste_Previews: PreviewProvider {
    static var previews: some View {
        teste()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
