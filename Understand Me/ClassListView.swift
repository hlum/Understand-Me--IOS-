//
//  ClassListView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct ClassListView: View {
    let colors: [Color] = [.accent, .secAccent, .blue, .brown, .orange, .cyan, .gray, .green, .indigo, .mint]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(1...10, id: \.self) { _ in
                NavigationLink {
                    
                } label: {
                    classItemView(className: "Swift入門", teacherName: "山田", homeworksCount: 5)
                }
            }
        }
        .navigationTitle("クラス一覧")
        .foregroundStyle(.primary)
    }
    
    @ViewBuilder
    private func classItemView(className: String, teacherName: String, homeworksCount: Int) -> some View {
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
                
                
                VStack(alignment: .leading) {
                    Text(teacherName)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "graduationcap")
                            .foregroundStyle(.accent.opacity(0.4))
                        Text("課題")
                            .fontWeight(.light)
                        
                        Text("\(homeworksCount) 件")
                    }
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

#Preview {
    NavigationView {
        ClassListView()
    }
}
