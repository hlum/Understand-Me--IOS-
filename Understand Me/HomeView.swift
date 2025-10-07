//
//  ContentView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    
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
                            .foregroundStyle(.blue)
                    }
                }
                
                VStack(spacing: 12) {
                    HomeworkListItemView(title: "Android Compose 基礎", dueDate: Date(), state: .generatingQuestions)
                    HomeworkListItemView(title: "HTML・CSS 実装課題", dueDate: Date(), state: .notAssigned)
                    HomeworkListItemView(title: "GitHub リポート提出", dueDate: Date(), state: .questionsGenerated)
                }
            }
            
            
            // MARK: - My Classes
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    
                } label: {
                    HStack {
                        Text("クラスリスト")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        Image(systemName: "arrow.forward")
                            .bold()
                            .foregroundStyle(.blue)
                    }
                }
                .foregroundStyle(.primary)
                
                LazyVGrid(columns: adaptiveColumn, spacing: 16) {
                    classCell(
                        className: "iOS プログラミング",
                        teacherName: "山田太郎先生"
                    )
                    classCell(
                        className: "Android プログラミング",
                        teacherName: "山田太郎先生"
                    )
                    classCell(
                        className: "Web プログラミング",
                        teacherName: "山田太郎先生"
                    )
                    classCell(
                        className: "コンテンツ制作",
                        teacherName: "山田太郎先生"
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
                Text("こんにちは 👋")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("24cm0112")
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
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .gray.opacity(0.5), radius: 6)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Class Card
    private func classCell(className: String, teacherName: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(className)
                .font(.headline)

            Text(teacherName)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(.background)
        .cornerRadius(20)
        .shadow(color: .primary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}


#Preview {
    HomeView()
}
