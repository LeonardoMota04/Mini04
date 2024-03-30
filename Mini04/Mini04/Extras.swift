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

