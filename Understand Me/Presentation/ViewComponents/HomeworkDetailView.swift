//
//  HomeworkDetailView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct HomeworkDetailView: View {
    var id: String
    @StateObject private var viewModel: HomeworkDetailViewModel
    
    
    init(
        id: String,
        homeworkUseCase: HomeworkUseCase = .init(homeworkRepository: LollipopHomeworkRepository()),
        classUseCase: ClassUseCase = .init(classRepository: LollipopClassRepository()),
        projectUseCase: ProjectUseCase = .init(projectRepository: LollipopProjectRepository()),
        authenticationUseCase: AuthenticationUseCase = .init(authenticationRepository: FirebaseAuthenticationRepository())
    ) {
        self._viewModel = .init(wrappedValue: .init(homeworkUseCase: homeworkUseCase, classUseCase: classUseCase, projectUseCase: projectUseCase, authenticationUseCase: authenticationUseCase))
        
        self.id = id
    }
    
    var body: some View {
        Group {
            if let homework = viewModel.homework {
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
                        answerQuizBtn(homeworkID: homework.id)
                    }else if homework.submissionState == .failed {
                        failedState(homeworkID: homework.id)
                    } else if homework.submissionState == .completed {
                        reviewNavBtn(homeworkID: homework.id)
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
            }
            
        }
        .task(id: id) {
            await viewModel.loadInfoOfHomework(homeworkID: id)
        }
    }
    
    
    private func failedState(homeworkID: String) -> some View {
        VStack {
            
            Button {
                Task {
                    await viewModel.retryQuestionGeneration(homeworkID: homeworkID)
                    await viewModel.loadInfoOfHomework(homeworkID: homeworkID)
                }
            } label: {
                Text("生成やり直す")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.accent)
            .cornerRadius(70)
            .padding()
            
            
            Button {
                
            } label: {
                Text("提出を取り消す")
                    .font(.headline)
                    .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(
                RoundedRectangle(cornerRadius: 70)
                    .stroke(style: .init())
            )
            .cornerRadius(70)
            .padding(.horizontal)
        }
        
    }
    
    
    private func reviewNavBtn(homeworkID: String) -> some View {
        VStack {
            NavigationLink {
                QuestionsView(homeworkID: homeworkID, mode: .review)
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
    
    private func answerQuizBtn(homeworkID: String) -> some View {
        NavigationLink {
            QuestionsView(homeworkID: homeworkID)
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
                text: $viewModel.homeworkLinkTxt
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
                Task {
                    await viewModel.uploadProject()
                }
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
        HomeworkDetailView(
            id:"",
            homeworkUseCase: HomeworkUseCase(homeworkRepository: TestHomeworkRepository()),
            classUseCase: ClassUseCase(classRepository: TestClassRepository()),
            projectUseCase: ProjectUseCase(projectRepository: TestProjectRepository()),
            authenticationUseCase: AuthenticationUseCase(authenticationRepository: TestAuthenticationRepository())
        )
    }
}
