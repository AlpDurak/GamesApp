//
//  UniversalButton.swift
//  GamesApp
//
//  Created by Alp on 21.04.2023.
//

import SwiftUI

struct UniversalButton: View {
    var label: String
    var textColor: Color = .blue
    var backgroundColor: Color = .white
    
    var body: some View {
        Text(label)
            .font(.system(size: 20, weight: .bold))
            .frame(width: 300, height: 60)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(10)
    }
}
