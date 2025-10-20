//
//  QuestionsView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import SwiftUI
import Combine

class QuestionsViewModel: ObservableObject {
    @Published var questionsWithChoices: [QuestionWithChoices] = []
    @Published var currentIndex = 0
    @Published var questionIDAndSelectedChoiceID: [String: String] = [:] // questionID: selectedChoiceID
    private var authenticationUseCase: AuthenticationUseCase
    private var questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase
    private var answerUseCase: AnswerUseCase
    init(
        authenticationUseCase: AuthenticationUseCase,
        questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase,
        answerUseCase: AnswerUseCase
    ) {
        self.authenticationUseCase = authenticationUseCase
        self.questionsWithChoicesUseCase = questionsWithChoicesUseCase
        self.answerUseCase = answerUseCase
    }
    
    @MainActor
    func loadALlQuestionsWithChoices(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("QuestionsViewModel.loadAllQuestionsWithChoices: ログイン中のUserがありません。")
            return
        }
        
        do {
            
            self.questionsWithChoices = try await questionsWithChoicesUseCase.fetchAll(
                homeworkID: homeworkID,
                userID: authDataResult.id
            )
            
        } catch {
            print("QuestionsViewModel.loadAllQuestionsWithChoices: \(error.localizedDescription)")
            // TODO: Show error to the user
        }
    }
    
    
    
    func postAnswer(questionID: String, homeworkID: String, selectedChoiceID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("QuestionsViewModel.postAnswer: ログイン中のUserがありません。")
            return
        }
        
        let answer = Answer(
            questionID: questionID,
            userID: authDataResult.id,
            selectedChoiceID: selectedChoiceID
        )
        
        do {
            let totalQuestions = questionsWithChoices.count
            try await answerUseCase.addAnswer(answer: answer, homeworkID: homeworkID, totalQuestions: totalQuestions)
        } catch {
            print("QuestionsViewModel.postAnswer: \(error.localizedDescription)")
            // TODO: Show error to the user
        }
    }
    
    
    
    func loadAnswersForReview(questionID: String) async {
        
    }
}

struct QuestionsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = QuestionsViewModel(
        authenticationUseCase: AuthenticationUseCase(authenticationRepository: FirebaseAuthenticationRepository()),
        questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase(questionsWithChoicesRepository: LollipopQuestionsWithChoicesRepository()),
        answerUseCase: AnswerUseCase(answerRepository: LollipopAnswerRepository())
    )
    
    var homeworkID: String
    var mode: QuestionViewMode = .answering
    
    var body: some View {
        VStack {
            if viewModel.questionsWithChoices.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                if mode == .answering {
                    QuestionAndChoicesItemView(
                        questionAndChoices: viewModel.questionsWithChoices[viewModel.currentIndex],
                        mode: mode,
                        isLastQuestion: viewModel.currentIndex == viewModel.questionsWithChoices.count - 1,
                        onClickNext: { selectedChoiceID in
                            Task {
                                await viewModel.postAnswer(
                                    questionID: viewModel.questionsWithChoices[viewModel.currentIndex].id,
                                    homeworkID: viewModel.questionsWithChoices[viewModel.currentIndex].homeworkID,
                                    selectedChoiceID: selectedChoiceID
                                )
                                
                                
                                if viewModel.currentIndex < viewModel.questionsWithChoices.count - 1 {
                                    withAnimation(.snappy) {
                                        viewModel.currentIndex += 1
                                    }
                                } else {
                                    // Quiz 終了、前のViewに戻る
                                    dismiss()
                                    
                                }
                            }
                        })
                } else {
                    ScrollView(.vertical) {
                        ForEach(viewModel.questionsWithChoices) { questionWithChoices in
                            QuestionAndChoicesItemView(
                                questionAndChoices: questionWithChoices,
                                mode: .review,
                                selectedChoiceIDFromServer: "cho_68f270f49274f1.15924140"
                            )
                        }
                    }
                }
            }
            
            Spacer()
        }
        .navigationTitle(mode == .answering ? "質問一覧" : "回答履歴")
        .task {
            await viewModel.loadALlQuestionsWithChoices(homeworkID: homeworkID)
        }
    }
}

#Preview {
    NavigationStack {
        QuestionsView(homeworkID: "")
    }
}
