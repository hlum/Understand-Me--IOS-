//
//  ContentView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            header
            
            
            // MARK: - Upcoming Homework
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    
                } label: {
                    HStack {
                        Text("提出期限が近い課題")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        Image(systemName: "arrow.forward")
                            .bold()
                            .foregroundStyle(.accent.opacity(0.3))
                    }
                }
                
                ScrollView(showsIndicators: false ) {
                    HomeworkListItemView(title: "Android Compose 基礎", dueDate: Date(), state: .generatingQuestions)
                    HomeworkListItemView(title: "HTML・CSS 実装課題", dueDate: Date(), state: .notAssigned)
                    HomeworkListItemView(title: "GitHub リポート提出", dueDate: Date(), state: .questionsGenerated)
                }
                .frame(height: 300)
            }
            
            
            // MARK: - My Classes
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    
                } label: {
                    HStack {
                        Text("マイクラス")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        Image(systemName: "arrow.forward")
                            .bold()
                            .foregroundStyle(.accent.opacity(0.3))
                    }
                }
                .foregroundStyle(.primary)
                
                LazyVGrid(columns: adaptiveColumn, spacing: 16) {
                    classCell(
                        className: "iOS プログラミング",
                        teacherName: "山田太郎先生",
                        homeworksCount: 3
                    )
                    classCell(
                        className: "Android プログラミング",
                        teacherName: "山田太郎先生",
                        homeworksCount: 10
                    )
                    classCell(
                        className: "Web プログラミング",
                        teacherName: "山田太郎先生"
                    )
                    classCell(
                        className: "コンテンツ制作",
                        teacherName: "山田太郎先生",
                        homeworksCount: 100
                    )
                }
                .padding(.horizontal)
            }
            
            Spacer(minLength: 40)
        }
        .padding(.vertical)
        .foregroundStyle(.primary)
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("こんにちは")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("24cm011288")
                    .font(.title3.bold())
            }
            
            Spacer()
            
            AsyncImage(url: URL(string: "https://e-quester.com/wp-content/uploads/2021/11/placeholder-image-person-jpg.jpg")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 55, height: 55)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.primary.opacity(0.3), lineWidth: 1))
        }
        .padding()
        .padding(.top, 20)
        .padding(.horizontal, 10)
        .background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.3))
    }
    
    // MARK: - Class Card
    private func classCell(className: String, teacherName: String, homeworksCount: Int = 0) -> some View {
        NavigationLink(destination: {
            ClassHomeworkView(className: className)
        }, label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(className)
                    .font(.headline)

                Text(teacherName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            
                
                HStack {
                    Image(systemName: "graduationcap")
                        .foregroundStyle(.accent.opacity(0.4))
                    Text("課題")
                        .fontWeight(.light)
                    
                    Spacer()
                    
                    Text("\(homeworksCount) 件")
                        .fontWeight(.regular)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.secAccent.opacity(0.4))
                        .foregroundColor(.primary)
                        .cornerRadius(12)

                }

            }
            .lineLimit(1)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            .background(.background)
            .cornerRadius(20)
            .shadow(color: .primary.opacity(0.2), radius: 8)
        })
    }
}


#Preview {
    NavigationStack {
        HomeView(selectedTab: .constant(1))
    }
}
