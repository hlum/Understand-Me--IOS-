//
//  HomeworkDetailView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct HomeworkDetailView: View {
    var title: String
    var description: String
    var homeworkState: HomeworkState
    var dueDate: Date
    var className: String
    
    @State private var homeworkLinkTxt: String = ""
    
    var body: some View {
        ScrollView {
            
            homeworkTitleDescription
            
            Divider()
            
            if homeworkState == .notAssigned {
                githubTxtFieldAndBtn
            } else if homeworkState == .generatingQuestions {
                nekoThinking
            } else if homeworkState == .questionsGenerated {
                answerQuizBtn
            } else if homeworkState == .completed {
                VStack {
                    NavigationLink {
                        
                    } label: {
                        Text("回答履歴を見る")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.accent)
                    .cornerRadius(70)
                }
                .padding()

            }
            
            Spacer()
        }
        .navigationTitle("課題の詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var answerQuizBtn: some View {
        NavigationLink {
            
        } label: {
            HStack {
                LottieView(filename: "AI")
                    .frame(width: 50, height: 50)
                Text("AI クイズに回答")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.accent)
            .cornerRadius(70)
            .padding()
        }
    }
    
    private var homeworkTitleDescription: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title.bold())
                .padding(.bottom, 7)
            
            HStack {
                Image(systemName: "graduationcap")
                Text(className)
            }
            
            HStack {
                Image(systemName: "calendar")
                Text("締切：" + formattedDate(dueDate))
            }
            .padding(.bottom, 12)
            
            Text(description)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(20)
        
    }
    
    private var nekoThinking: some View {
        VStack(alignment: .center) {
            LottieView(filename: "nekoThinking")
                .frame(width: 300, height: 300)
            
            Text("猫ちゃん考え中です。\n クイズが用意出来次第通知します。")
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var githubTxtFieldAndBtn: some View {
        VStack(alignment: .leading) {
            Text("GitHubリポジトリ　URL")
                .font(.headline)
            
            TextField(
                "例: https: //github.com/your-username/your-repository",
                text: $homeworkLinkTxt
            )
            .padding()
            .frame(height: 55)
            .background(
                RoundedRectangle(cornerRadius: 50).stroke()
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .textContentType(.URL)
            .keyboardType(.URL)
            .foregroundColor(.primary)
            
            Text("無効なURLです。")
                .font(.caption)
                .foregroundStyle(.red)
                .frame(height: 10)
            
            Button {
                
            } label: {
                Text("提出する")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.accent)
                    .cornerRadius(70)
            }
            .foregroundStyle(.white)
            
        }
        .padding()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
}

#Preview {
    NavigationStack {
        HomeworkDetailView(title: "リアクティブプログラミング基礎", description: "この課題では、リアクティブプログラミングの基本的な概念とRxJSの利用法を学びます。以下のトピックをカバーします。 1. オブザーバブルとオブザーバーの作成 2. オペレーターの利用", homeworkState: .completed, dueDate: Date(), className: "IOS プログラミング")
    }
}
