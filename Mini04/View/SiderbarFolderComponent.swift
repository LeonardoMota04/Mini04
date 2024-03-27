//
//  SiderbarFolderComponent.swift
//  Mini04
//
//  Created by luis fontinelles on 26/03/24.
//

import SwiftUI

struct SiderbarFolderComponent: View {
    var body: some View {
        ZStack {
            
            CustomRoundedRectangle()
            HStack {
                Spacer()
                VStack {
                    CustomTag()
                        .frame(width: 40, height: 40)
                    Spacer()
                }
            }
            
        }
        .frame(width: 340, height: 74)
    }
}




struct CustomRoundedRectangle: Shape {

    var rounded: CGFloat = 10

    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Iniciar o caminho no canto superior esquerdo
        path.move(to: CGPoint(x: 0, y: 0 ))
        
        // Adicionar linha até o canto superior direito
        path.addLine(to: CGPoint(x: 275 - rounded, y: 0))
        path.addArc(center: CGPoint(x: 275 - rounded, y: 0 + 10),
                    radius: rounded,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: -40),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 295 - rounded, y: 18))
        
        // adicionar linha no meio esquerdo
        let controlPoint = CGPoint(x: 290, y: 24 )
        path.addQuadCurve(to: CGPoint(x: 295, y: 24), control: controlPoint)
//        path.addQuadCurve(to: CGPoint(x: 300 , y: 24 ), control: CGPoint(x: 300, y: 29))

        
        //adicionar linha no meio direito
        path.addLine(to: CGPoint(x: 340 - rounded, y: 24))
        path.addArc(center: CGPoint(x: 340 - rounded, y: 24 + rounded),
                    radius: rounded,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        // Adicionar linha até o canto inferior direito com arredondamento
        path.addLine(to: CGPoint(x: 340, y: 72 - rounded))
        path.addArc(center: CGPoint(x: 340 - rounded, y: 72 - rounded),
                    radius: rounded,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        // Adicionar linha até o canto inferior esquerdo com arredondamento
        path.addLine(to: CGPoint(x: 0 + rounded, y: 72))
        path.addArc(center: CGPoint(x: 0 + rounded, y: 72 - rounded),
                    radius: rounded,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        
        // Adicionar linha de volta para o canto superior esquerdo com arredondamento
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rounded))
        path.addArc(center: CGPoint(x: rect.minX + rounded, y: rect.minY + rounded),
                    radius: rounded,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        // Fechar o caminho
        path.closeSubpath()
        
        return path
    }
}


struct CustomTag: Shape {
    var rounded: CGFloat = 5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Coordenadas dos vértices do trapézio
        let topLeft = CGPoint(x: -21, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: -10, y: 19)
        let bottomRight = CGPoint(x: rect.maxX, y: 19)
        
        path.move(to: CGPoint(x: topLeft.x + rounded , y: topLeft.y))
        
        path.addLine(to: CGPoint(x: topRight.x - rounded, y: topRight.y))
        
        // Curva superior direita
        let topRightControl1 = CGPoint(x: topRight.x - (rounded * 0.55), y: topRight.y)
        let topRightControl2 = CGPoint(x: topRight.x, y: topRight.y + (rounded * 0.45))
        path.addCurve(to: CGPoint(x: topRight.x, y: topRight.y + rounded), control1: topRightControl1, control2: topRightControl2)
        
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - rounded))
        
        // Curva inferior direita
        let bottomRightControl1 = CGPoint(x: bottomRight.x, y: bottomRight.y - (rounded * 0.45))
        let bottomRightControl2 = CGPoint(x: bottomRight.x - (rounded * 0.55), y: bottomRight.y)
        path.addCurve(to: CGPoint(x: bottomRight.x - rounded, y: bottomRight.y), control1: bottomRightControl1, control2: bottomRightControl2)
        
        path.addLine(to: CGPoint(x: bottomLeft.x + rounded, y: bottomLeft.y))
        
        // Curva inferior esquerda
        let bottomLeftControl1 = CGPoint(x: bottomLeft.x + (rounded * 0.55), y: bottomLeft.y)
        let bottomLeftControl2 = CGPoint(x: bottomLeft.x, y: bottomLeft.y - (rounded * 0.45))
        path.addCurve(to: CGPoint(x: bottomLeft.x - 3 , y: bottomLeft.y - rounded), control1: bottomLeftControl1, control2: bottomLeftControl2)
        
        path.addLine(to: CGPoint(x: topLeft.x + 2, y: topLeft.y + rounded + 2))
        
        // Curva superior esquerda
        let topLeftControl1 = CGPoint(x: topLeft.x, y: topLeft.y + (rounded * 0.45))
        let topLeftControl2 = CGPoint(x: topLeft.x + (rounded * 0.55), y: topLeft.y)
        path.addCurve(to: CGPoint(x: topLeft.x + rounded, y: topLeft.y), control1: topLeftControl1, control2: topLeftControl2)
        
        return path
    }
}


#Preview {
    SiderbarFolderComponent()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}