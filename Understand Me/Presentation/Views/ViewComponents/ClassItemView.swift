//
//  ClassItemView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import SwiftUI

struct ClassItemView: View {
    
    var classID: String
    var className: String
    var teacherName: String
    let colors: [Color] = [.accent, .secAccent, .blue, .brown, .orange, .cyan, .gray, .green, .indigo, .mint]
    
    var body: some View {
        let firstCharOfClassName = className.first!.uppercased()
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(colors.randomElement() ?? .accent)
                Text(firstCharOfClassName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading) {
                Text(className)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.bottom, 4)
                    .lineLimit(1)
                
                
                VStack(alignment: .leading) {
                    Text(teacherName)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
        .cornerRadius(20)
        .shadow(color: .primary.opacity(0.2), radius: 2)
        .padding(.horizontal)
    }
}
