//
//  CustomModalViewer.swift
//  Mini04
//
//  Created by luis fontinelles on 01/04/24.
//

import SwiftUI

struct CustomModalViewer: View {
  @State private var isShowingModal = false
  @State private var selectedTraining: Int?
  private var trainingArray = [1, 2, 3, 4, 5, 7, 8, 9, 10]

  var body: some View {
    ZStack {
      if isShowingModal {
        ScrollViewReader(content: { proxy in
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 40) {
              ForEach(trainingArray, id: \.self) { index in
                modalView(isShowingModal: $isShowingModal, trainingArray: index)
//                  .id(selectedTraining)
              }
            }
            .frame(maxWidth: .infinity)
          }
//          .disabled(true)
          .scrollTargetLayout()
          .scrollTargetBehavior(.paging)
          .defaultScrollAnchor(.center)
          .scrollPosition(id: $selectedTraining, anchor: .center)
          .onAppear(perform: {
            if let selectedTraining = selectedTraining {
              proxy.scrollTo(selectedTraining, anchor: .center)
            }
          })
        })
          
        .zIndex(1)
      }
      VStack {
        ForEach(trainingArray, id: \.self) { buttonIndex in
          ZStack {
            Button {
              isShowingModal.toggle()
              selectedTraining = buttonIndex
            } label: {
              ZStack {
                RoundedRectangle(cornerRadius: 10)
                  .frame(height: 50)
                Text(String(buttonIndex))
                  .foregroundStyle(.black)
                  .bold()
                  .font(.largeTitle)
              }
            }
            .buttonStyle(.plain)
            .focusable(false)
          }
        }
      }
      .padding()
    }
    .padding()
  }
}

struct modalView: View {
  @Binding var isShowingModal: Bool
//  @Binding var selectedTraining: Int?
   var trainingArray: Int

  var body: some View {
    ZStack (alignment: .top) {
      RoundedRectangle(cornerRadius: 10)
        .foregroundStyle(.white)
        .frame(width: 300)
      VStack {
        HStack {
          VStack {
            Button {
              isShowingModal.toggle()
            } label: {
              Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
             
            Spacer()
          }
          Spacer()
        }
        Text(String(trainingArray))
          .font(.largeTitle)
          .foregroundStyle(.black)
          .bold()
        Spacer()
      }
      .padding()
    }
  }
}

#Preview {
  CustomModalViewer()
}
