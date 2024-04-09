//
//  Extras.swift
//  Mini04
//
//  Created by luis fontinelles on 27/03/24.
//

import SwiftUI
// remover a borda de selecao azul ao redor do textfield
// https://stackoverflow.com/questions/59754983/how-to-get-rid-of-the-blue-selection-border-around-swiftui-textfields
extension NSTextField {
        open override var focusRingType: NSFocusRingType {
                get { .none }
                set { }
        }
}

extension CGFloat {
    // Essa funcoes calculam o a porcentagem que o componente tem que ter de acordo como o tamanho da tela cheia, de acordo com o prototipo. Assim fica mais facil de calcular o AutoLayout
    static func calculateWidthPercentageFullScreen(componentWidth: CGFloat, witdhScreenSize: CGFloat) -> CGFloat {
        let screenWidth: CGFloat = 1512
        let widthPercentage = (componentWidth / screenWidth) * 100
        
        let widthRelativeSize = witdhScreenSize * widthPercentage
        
        return widthRelativeSize
    }
    
    static func calculateHeightPercentageFullScreen(componentHeight: CGFloat, heightScreenSize: CGFloat) ->  CGFloat {
        let screenHeight: CGFloat = 982
        let heightPercentage = (componentHeight / screenHeight) * 100
        
        let heightRelativeSize = heightScreenSize * heightPercentage
        
        return heightRelativeSize
    }
    
    static func calculateWidthPercentageModal(componentWidth: CGFloat, witdhScreenSize: CGFloat) -> CGFloat {
        let screenWidth: CGFloat = 1512
        let widthPercentage = (componentWidth / screenWidth) * 100
        
        let widthRelativeSize = witdhScreenSize * widthPercentage
        
        return widthRelativeSize
    }
    
    static func calculateHeightPercentageModal(componentHeight: CGFloat, heightScreenSize: CGFloat) ->  CGFloat {
        let screenHeight: CGFloat = 1444
        let heightPercentage = (componentHeight / screenHeight) * 100
        
        let heightRelativeSize = heightScreenSize * heightPercentage
        
        return heightRelativeSize
    }
    
    static func calculateFontSize(componentWidth: CGFloat, desiredFontSize: CGFloat) -> CGFloat {
        // Calcular o tamanho médio do componente
   //     let averageSize = (componentWidth + componentHeight) / 2
        
        // Calcular a porcentagem do tamanho da fonte em relação ao tamanho médio do componente
        let fontSizePercentage = (desiredFontSize / componentWidth)
        
        // Retornar o tamanho da fonte relativo ao tamanho do componente
        return fontSizePercentage
    }
}

