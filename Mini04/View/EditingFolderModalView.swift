//
//  EditingFolderModalView.swift
//  Mini04
//
//  Created by Leonardo Mota on 09/04/24.
//

import SwiftUI

// MARK: - MODAL DE EDITAR PASTA
struct EditingFolderModalView: View {
    @ObservedObject var folderVM: FoldersViewModel
    @Binding var isModalPresented: Bool

    // NOVAS INFORMACOES
    @State private var newPresentation_Name: String
    @State private var newPresentation_Date: Date
    @State private var newPresentation_Duration: Int
    @State private var newPresentation_Goal: String
    

    // associando as antigas informacoes
    init(folderVM: FoldersViewModel, isModalPresented: Binding<Bool>) {
        self.folderVM = folderVM

        _newPresentation_Name = State(initialValue: folderVM.folder.nome)
        _newPresentation_Date = State(initialValue: folderVM.folder.dateOfPresentation)
        _newPresentation_Duration = State(initialValue: folderVM.folder.tempoDesejado)
        _newPresentation_Goal = State(initialValue: folderVM.folder.objetivoApresentacao)

        self._isModalPresented = isModalPresented
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Editar Apresentação")
                .font(.title)
                .bold()
                .padding(.bottom, 40)

            ZStack {
                // DURAÇÃO e TIPO
                HStack {
                    CustomDurationPickerView(selectedSortByOption: $newPresentation_Duration)
                    PickerPresentationTypeView(goalText: $newPresentation_Goal)
                }
                // NOME e DATA
                HStack {
                    TextFieldPresentationNameView(folderName: $newPresentation_Name)
                    DatePickerPresentationDateView(presentationDate: $newPresentation_Date)
                }
                .padding(.bottom, 200)
            }
            .padding(.horizontal, 30)

            HStack {
                Spacer()
                Button {
                    withAnimation {
                        // se o nome foi alterado
                        if newPresentation_Name != folderVM.folder.nome {
                            folderVM.folder.nome = newPresentation_Name
                        }
                        // se a data foi alterada
                        if newPresentation_Date != folderVM.folder.dateOfPresentation {
                            folderVM.folder.dateOfPresentation = newPresentation_Date
                        }
                        // se a duração foi alterada
                        if newPresentation_Duration != folderVM.folder.tempoDesejado {
                            folderVM.folder.tempoDesejado = newPresentation_Duration
                        }
                        // se o objetivo foi alterado
                        if newPresentation_Goal != folderVM.folder.objetivoApresentacao {
                            folderVM.folder.objetivoApresentacao = newPresentation_Goal
                        }
                        isModalPresented = false
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 140, height: 50)
                        .foregroundColor(.lightDarkerGreen)
                        .overlay {
                            Text("Salvar Edição")
                                .font(.title3)
                                .bold()
                        }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                Spacer()
            }

        }
        .padding(.horizontal, 20)
        .frame(width: 730, height: 520)
        .background(Color.lightLighterGray)
        .preferredColorScheme(.light)
    }
}
