//
//  CreateFolderModalView.swift
//  Mini04
//
//  Created by Leonardo Mota on 07/04/24.
//

import SwiftUI

// MARK: - MODAL DE CRIAR PASTA
struct CreatingFolderModalView: View {
    @ObservedObject var presentationVM: ApresentacaoViewModel
    @State var presentation_Duration: Int = 0
    @State var presentation_Type: String = ""
    @State var presentation_Name: String = ""
    @State var presentation_Date: Date = Date()
    
    @Binding var isModalPresented: Bool
    
    var isFormValid: Bool {
        return !presentation_Name.isEmpty && !presentation_Type.isEmpty && presentation_Duration > 0
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Criar Nova Apresentação")
                .font(.title)
                .bold()
                .padding(.bottom, 40)
    
            ZStack {
                // DURAÇÃO e TIPO
                HStack {
                    CustomDurationPickerView(selectedSortByOption: $presentation_Duration)
                    PickerPresentationTypeView(goalText: $presentation_Type)
                }
                // NOME e DATA
                HStack {
                    TextFieldPresentationNameView(folderName: $presentation_Name)
                    DatePickerPresentationDateView(presentationDate: $presentation_Date)
                }
                .padding(.bottom, 200)
            }
            .padding(.horizontal, 30)

            HStack {
                Spacer()
                Button {
                    withAnimation {
                        presentationVM.createNewFolder(name: presentation_Name,
                                                       pretendedTime: presentation_Duration,
                                                       presentationGoal: presentation_Type)
                        isModalPresented = false
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 100, height: 50)
                        .foregroundColor(.lightDarkerGreen)
                        .overlay {
                            Text("Salvar")
                                .font(.title3)
                                .bold()
                        }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .disabled(!isFormValid) // desabilita o botão se o formulário não estiver válido
                Spacer()
            }
            
        }
        .padding(.horizontal, 20)
        .frame(width: 730, height: 520)
        .background(Color.lightLighterGray)
        .preferredColorScheme(.light)
    }
}


// MARK: - TEXTFIELD NOME DA APRESENTAÇÃO
struct TextFieldPresentationNameView: View {
    @Binding var folderName: String
    @State private var isHovered = false
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Título da sua Apresentação")
                .font(.body)
                .foregroundStyle(.gray)

            TextField("", text: $folderName, onEditingChanged: { editing in
                self.isEditing = editing
            })
                .textFieldStyle(.plain)
                .padding(.vertical, 22)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color.lightWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder((isHovered && !isEditing) ? Color(.darkGray) : (isEditing ? Color(.lightDarkerGreen) : Color(.gray)), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10)) 
                        .shadow(color: isEditing ? Color.black : .clear, radius: isEditing ? 5 : 0) // Aplicando sombra ao RoundedRectangle
                )

                .onChange(of: folderName) { _, newValue in
                    if newValue.count > 23 {
                        folderName = String(newValue.prefix(23))
                    }
                }
        }

        .onHover { hovering in
            withAnimation {
                self.isHovered = hovering && !isEditing
            }
        }
    }
}

// MARK: - DATEPICKER DATA DA APRESENTAÇÃO
struct DatePickerPresentationDateView: View {
    @Binding var presentationDate: Date
    @State private var isShowingDatePicker: Bool = false
    @State private var isHovered = false
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Data da Apresentação")
                .font(.body)
                .foregroundStyle(.gray)

            HStack {
                TextField("DD/MM/AAAA", text: formatDate($presentationDate), onEditingChanged: { editing in
                    withAnimation {
                        self.isEditing = editing
                        self.isShowingDatePicker = editing
                    }
                })
                .textFieldStyle(.plain)
                
                Button {
                    withAnimation {
                        isShowingDatePicker.toggle()
                    }
                } label: {
                    Image(systemName: isShowingDatePicker ? "calendar.circle.fill" : "calendar.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle((isHovered && !isEditing) ? Color(.darkGray) : (isEditing ? Color(.lightDarkerGreen) : Color(.gray)))
                        .bold(isEditing)
                }
                .buttonStyle(.plain)
                .overlay(alignment: .topTrailing) {
                    if isShowingDatePicker {
                        DatePicker("", selection: $presentationDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                        //.clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 10)
                            .padding(.top, 30)
                            .onChange(of: presentationDate) { _, _ in
                                isShowingDatePicker = false
                            }
                    }
                }
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color.lightWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder((isHovered && !isEditing) ? Color(.darkGray) : (isEditing ? Color(.lightDarkerGreen) : Color(.gray)), lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: isEditing ? Color.black : .clear, radius: isEditing ? 5 : 0) // Aplicando sombra ao RoundedRectangle
            )
        }
        .onHover { hovering in
            self.isHovered = hovering
        }
    }
    // formatar datepicker para dd/mm/yyyy
    private func formatDate(_ date: Binding<Date>) -> Binding<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        return Binding<String>(
            get: { formatter.string(from: date.wrappedValue) },
            set: { newValue in
                if let newDate = formatter.date(from: newValue) {
                    date.wrappedValue = newDate
                }
            }
        )
    }
}

// MARK: - PICKER DURAÇÃO DA APRESENTAÇÃO
struct CustomDurationPickerView: View {
    let timeStamps = [5, 8, 10, 15, 20]
    @Binding var selectedSortByOption: Int
    @State private var customTime: String = ""
    @State private var isHovered = false
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Duração da Apresentação")
                .foregroundStyle(.gray)
                .font(.body)
            
            ZStack (alignment: .trailing){
                HStack {
                    TextField("00:00", text: $customTime, onEditingChanged: { editing in
                        self.isEditing = editing
                    })
                        .textFieldStyle(.plain)
                    Spacer()
                    Image(systemName: "timer")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle((isHovered && !isEditing) ? Color(.darkGray) : (isEditing ? Color(.lightDarkerGreen) : Color(.gray)))
                        .bold(isEditing)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color.lightWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder((isHovered && !isEditing) ? Color(.darkGray) : (isEditing ? Color(.lightDarkerGreen) : Color(.gray)), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: isEditing ? Color.black : .clear, radius: isEditing ? 5 : 0) // Aplicando sombra ao RoundedRectangle
                )
                // MENU
                Menu {
                    Section(header: Text("Sugestões")) {
                        ForEach(timeStamps, id: \.self) { time in
                            Button("\(String(time)) minutos") {
                                selectedSortByOption = time
                                customTime = formatTime(time)
                            }
                        }
                    }
                } label: {
                    EmptyView()
                }

                .frame(width: 50, height: 50)
                .background(Color.clear)
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .padding(.trailing, 5)
            }

        }
        .onHover { hovering in
            withAnimation {
                self.isHovered = hovering && !isEditing
            }
        }
    }
    
    func formatTime(_ time: Int) -> String {
        let minutes = time
        let formattedMinutes = String(format: "%02d", minutes)
        return "\(formattedMinutes):00"
    }
}

// MARK: - PICKER TIPO DE APRESENTAÇÃO
struct PickerPresentationTypeView: View {
    @Binding var goalText: String
    let goal = ["Apresentação de Vendas", "Apresentação de Eventos", "Apresentação de Pitch", "Apresentação de Projetos", "Apresentação Acadêmica"]
    let goalsImages = ["dollarsign.circle.fill", "hands.clap.fill", "megaphone.fill", "briefcase.fill", "graduationcap.fill"]
    @State private var isPopoverVisible = false // Estado para controlar a visibilidade do popover
    @State private var selectedOptionIndex: Int? // Estado para rastrear o item do menu selecionado
    @State private var isHovered = false
    @State private var isEditing = false
    
    // Textos para os popovers
    let popoverTexts = [
        "Destacar os benefícios do produto ou serviço, despertando o interesse do público e incentivando a ação, através de uma comunicação clara e persuasiva.",
        "Compartilhar conhecimento de forma envolvente e inspiradora, promovendo o engajamento da audiência e incentivando a troca de ideias, agregando valor do evento.",
        "Transmitir de forma convincente a ideia de negócio ou projeto, destacando o problema a ser resolvido, a solução proposta e o potencial de mercado, com o intuito de atrair investidores ou parceiros.",
        "Fornecer informações relevantes e úteis sobre um determinado tema, garantindo que a audiência compreenda e assimile o conteúdo apresentado, utilizando uma linguagem acessível e exemplos claros.",
        "Apresentar pesquisa original, defender uma tese ou compartilhar conhecimento dentro de um contexto educacional, utilizando uma abordagem estruturada e argumentativa para persuadir e informar o público acadêmico."
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Tipo de Apresentação")
                .font(.body)
                .foregroundStyle(.gray)
            
            Menu {
                ForEach(goal.indices, id: \.self) { index in
                    Button {
                        goalText = goal[index]
                        selectedOptionIndex = index
                        isPopoverVisible.toggle() // Ativa o popover quando um item do menu é selecionado
                    } label: {
                        HStack {
                            Image(systemName: goalsImages[index])
                            Text(goal[index])
                        }
                    }
                }
            } label: {
                Text(goalText)
            }
            .onTapGesture { self.isEditing.toggle() }
            .menuStyle(.borderlessButton)
            
            .padding(.vertical, 22)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color.lightWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder((isHovered && !isEditing) ? Color(.darkGray) : (isEditing ? Color(.lightDarkerGreen) : Color(.gray)), lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: isEditing ? Color.black : .clear, radius: isEditing ? 5 : 0) // Aplicando sombra ao RoundedRectangle
            )          
            
            .onChange(of: isPopoverVisible) { _, newValue in
                self.isEditing = newValue // isEditing como true quando o popover estiver visível
            }

            .onHover { hovering in
                withAnimation {
                    self.isHovered = hovering && !isEditing
                }
            }
            // POPOVER DE CADA APRESENTAÇÃO
            .popover(isPresented: $isPopoverVisible, arrowEdge: .trailing) {
                if let selectedIndex = selectedOptionIndex {
                    VStack(alignment: .leading) {
                        Text("Qual o objetivo?").bold()
                        Text(popoverTexts[selectedIndex])
                            .font(.footnote)
                    }
                    .padding()
                    .frame(width: 280, height: 120)
                }
            }
            
        }
    }
}
