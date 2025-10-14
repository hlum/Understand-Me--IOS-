//
//  HomeworkDetailView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct HomeworkDetailView: View {
    var id: String
    
    @StateObject private var viewModel: HomeworkDetailViewModel = HomeworkDetailViewModel(homeworkUseCase: HomeworkUseCase(homeworkRepository: LollipopHomeworkRepository()), classUseCase: ClassUseCase(classRepository: LollipopClassRepository()))
    @State private var homeworkLinkTxt: String = ""
    
    var body: some View {
        Group {
            if let homework = viewModel.homework,
               let classInfo = viewModel.classDetail
            {
                ScrollView {
                    if let classInfo = viewModel.classDetail {
                        homeworkTitleDescription(homework: homework, classInfo: classInfo)
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    Divider()
                    
                    
                    if homework.submissionState == .notAssigned {
                        githubTxtFieldAndBtn
                    } else if homework.submissionState == .generatingQuestions {
                        nekoThinking
                    } else if homework.submissionState == .questionGenerated {
                        answerQuizBtn
                    } else if homework.submissionState == .completed {
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
                .refreshable {
                    await viewModel.loadInfoOfHomework(homeworkID: id)
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .task {
                        await viewModel.loadInfoOfHomework(homeworkID: id)
                    }
            }
        }
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
    
    private func homeworkTitleDescription(homework: HomeworkWithStatus, classInfo: Class) -> some View {
        VStack(alignment: .leading) {
            Text(homework.title)
                .font(.title.bold())
                .padding(.bottom, 7)
            
            HStack {
                Image(systemName: "graduationcap")
                Text(classInfo.name)
            }
            
            HStack {
                Image(systemName: "calendar")
                Text("締切：" + formattedDate(homework.dueDate ?? Date()))
            }
            .padding(.bottom, 12)
            
            Text(homework.description)
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
        HomeworkDetailView(id:"")
    }
}
