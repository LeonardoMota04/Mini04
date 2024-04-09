//
//  ModalTreinoView.swift
//  Mini04
//
//  Created by luis fontinelles on 09/04/24.
//

import SwiftUI

struct ModalTreinoView: View {
    @Binding var isShowingModal: Bool
    @Binding var selectedTrainingIndex: Int?
    @Binding var filteredTrainings: [TreinoModel]
    @Binding var apresentacaoreference: FoldersViewModel?

    @State private var offsetView1: CGFloat = -2000
    @State private var offsetView2: CGFloat = 0
    @State private var offsetView3: CGFloat = 2000

    var body: some View {
        HStack {
            Spacer()
            //botao de retornar uma view
            Button {
                withAnimation {
                    if selectedTrainingIndex! < filteredTrainings.count - 1 {
                        selectedTrainingIndex! += 1
                    }
                }
            } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)

            }
            .disabled(selectedTrainingIndex! == filteredTrainings.count - 1 ? true : false)
            .buttonStyle(.plain)
            .padding()
            ZStack(alignment: .top) {
//                                sombra
                Color.black
                    .frame(maxHeight: .infinity)
                    .frame(width: 958)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y: 25)
                    .offset(x: offsetView1)
                    .zIndex(0)
                    .blur(radius: 3)
                    .opacity(0.6)
                
                TreinoView(folderVM: apresentacaoreference!, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
                    .frame(maxHeight: .infinity)
                    .frame(width: 958)
                    .background(Color("light_LighterGray"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y: 25)
                    .offset(x: offsetView1)
                    .zIndex(1)
                    .onChange(of: selectedTrainingIndex) { oldValue, newValue in
                        guard let previewsIndex = oldValue else { return }
                        guard let afterIndex = newValue else { return }

                        if previewsIndex < afterIndex {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                offsetView1 = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                offsetView1 = -2000
                            }
                        }
                    }
                Color.black
                    .frame(maxHeight: .infinity)
                    .frame(width: 958)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y: 25)
                    .offset(x: offsetView2)
                    .zIndex(0)
                    .blur(radius: 3)
                    .opacity(0.6)

                TreinoView(folderVM: apresentacaoreference!, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
                    .frame(maxHeight: .infinity)
                    .frame(width: 958)
                    .background(Color("light_LighterGray"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y:25)
                    .offset(x: offsetView2)
                    .onChange(of: selectedTrainingIndex) { oldValue, newValue in
                        guard let previewsIndex = oldValue else { return }
                        guard let afterIndex = newValue else { return }
                        if previewsIndex < afterIndex {

                            withAnimation(.easeInOut(duration: 0.5)) {
                                offsetView2 = 2000
                            }

                            // Aguarde um tempo para que a animação seja concluída
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                offsetView2 = 0
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                offsetView2 = -2000
                            }

                            // Aguarde um tempo para que a animação seja concluída
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                offsetView2 = 0
                            }
                        }
                    }
                Color.black
                    .frame(maxHeight: .infinity)
                    .frame(width: 958)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y: 25)
                    .offset(x: offsetView3)
                    .zIndex(0)
                    .blur(radius: 3)
                    .opacity(0.6)
                TreinoView(folderVM: apresentacaoreference!, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
                    .frame(maxHeight: .infinity)
                    .frame(width: 958)
                    .background(Color("light_LighterGray"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y: 25)
                    .offset(x: offsetView3)
                    .zIndex(1)
                    .onChange(of: selectedTrainingIndex) { oldValue, newValue in
                        guard let previewsIndex = oldValue else { return }
                        guard let afterIndex = newValue else { return }

                        if previewsIndex > afterIndex {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                offsetView3 = 0
                            }

                            // Aguarde um tempo para que a animação seja concluída
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                offsetView3 = 2000
                            }
                        }
                    }
            }
            // botao de passar uma view
            Button {
                withAnimation {
                    if selectedTrainingIndex! > 0 {
                        selectedTrainingIndex! -= 1
                    }
                }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(.plain)
            .disabled(selectedTrainingIndex == 0  ? true : false)
            .padding()
            Spacer()
        }
        .zIndex(1)
    }
}
