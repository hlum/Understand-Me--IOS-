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
        authenticationUseCase: AuthenticationUseCase = .init(authenticationRepository: FirebaseAuthenticationRepository()),
        resultUseCase: ResultUseCase = .init(resultRepo: LollipopResultRepository())
    ) {
        self._viewModel = .init(wrappedValue: .init(homeworkUseCase: homeworkUseCase, classUseCase: classUseCase, projectUseCase: projectUseCase, authenticationUseCase: authenticationUseCase, resultUseCase: resultUseCase))
        
        self.id = id
    }
    
    var body: some View {
        Group {
            if let homework = viewModel.homework {
                ScrollView {
                    if let classInfo = viewModel.classDetail {
                        homeworkTitleDescription(homework: homework, classInfo: classInfo)
                    } else {
                        homeworkTitleDescription(homework: homework, classInfo: nil)
                            .redacted(reason: .placeholder)
                    }
                    Divider()
                    
                    
                    if homework.submissionState == .notAssigned {
                        githubTxtFieldAndBtn(homeworkID: homework.id)
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
                    await viewModel.loadResult(homeworkID: id)
                }
            } else {
                HomeworkDetailSkeleton()
            }
            
        }
        .task(id: id) {
            await viewModel.loadInfoOfHomework(homeworkID: id)
            await viewModel.loadResult(homeworkID: id)
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
                Task {
                    await viewModel.cancelHomeworkSubmission(homeworkID: homeworkID)
                    await viewModel.loadInfoOfHomework(homeworkID: homeworkID)
                }
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
    
    @ViewBuilder
    private func homeworkTitleDescription(
        homework: HomeworkWithStatus,
        classInfo: Class?
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(homework.title)
                    .font(.title.bold())
                    .padding(.bottom, 7)
                
                Spacer()
                
                if let score = viewModel.result?.score {
                    Text("\(score)点")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            Circle()
                                .stroke(lineWidth: 4)
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.accent, .secAccent]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                        .padding(.trailing, 20)
                }
            }
            
            HStack {
                Image(systemName: "graduationcap")
                Text(classInfo?.name ?? "クラス名")
            }
            
            HStack {
                Image(systemName: "calendar")
                if let dueDate = homework.dueDate {
                    Text("締切：" + formattedDate(dueDate))
                } else  {
                    Text("締切期限未設定")
                }
            }
            .padding(.bottom, 12)
            
            Text(homework.description ?? "説明はありません。")
                
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
    
    
    private func githubTxtFieldAndBtn(homeworkID: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            // Title
            Text("提出リンク (GitHub または Google Drive)")
                .font(.headline)

            // TextField
            VStack(spacing: 4) {
                TextField(
                    "例: https:// github.com/your-username/your-repository",
                    text: $viewModel.homeworkLinkTxt
                )
                .padding(.horizontal, 20)
                .frame(height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 200)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 200)
                        .stroke(Color.accent.opacity(0.4), lineWidth: 1.5)
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textContentType(.URL)
                .keyboardType(.URL)
                .animation(.easeInOut(duration: 0.15), value: viewModel.homeworkLinkTxt)
            }

            // Info message
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Google Driveで提出する場合は、ファイルを圧縮し、\n「リンクを知っている全員がアクセス可能」に設定してください。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, -4)

            // Error message
            if viewModel.showInputError {
                Text(viewModel.inputErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
                    .padding(.top, -8)
            }

            // Submit button
            Button {
                Task {
                    await viewModel.uploadProject()
                    await viewModel.loadInfoOfHomework(homeworkID: homeworkID)
                }
            } label: {
                Text("提出する")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        viewModel.homeworkLinkTxt.isEmpty
                        ? Color.gray.opacity(0.4)
                        : Color.accentColor
                    )
                    .foregroundColor(.white)
                    .cornerRadius(70)
                    .animation(.easeInOut, value: viewModel.homeworkLinkTxt.isEmpty)
            }
            .disabled(viewModel.homeworkLinkTxt.isEmpty)

        }
        .padding(.horizontal)
        .padding(.vertical, 12)
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
            authenticationUseCase: AuthenticationUseCase(authenticationRepository: TestAuthenticationRepository()), resultUseCase: ResultUseCase(resultRepo: TestResultRepository()))
    }
}
