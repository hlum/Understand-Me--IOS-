//
//  QuestionsView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import SwiftUI
import AlertToast

struct QuestionsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: QuestionsViewModel
    
    var homeworkID: String
    var mode: QuestionViewMode
    
    
    init(
        authenticationRepository: AuthenticationRepository = FirebaseAuthenticationRepository(),
        questionsWithChoicesRepository: QuestionsWithChoicesRepository = LollipopQuestionsWithChoicesRepository(),
        answerRepository: AnswerRepository = LollipopAnswerRepository(),
        homeworkID: String,
        mode: QuestionViewMode = .answering
    ) {
        self._viewModel = .init(
            wrappedValue: .init(
                authenticationUseCase: AuthenticationUseCase(authenticationRepository: authenticationRepository),
                questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase(questionsWithChoicesRepository: questionsWithChoicesRepository),
                answerUseCase: AnswerUseCase(answerRepository: answerRepository)
            )
        )
        
        self.homeworkID = homeworkID
        self.mode = mode
    }
    
    
    var body: some View {
        VStack {
            if viewModel.isLoading || viewModel.questionsWithChoices.isEmpty {
                QuestionsViewSkeleton()
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
                    .id(viewModel.questionsWithChoices[viewModel.currentIndex].id)
                    .task {
                        //　回答を始めたのを記録するため空の回答を送信しとく
                        await viewModel.postAnswer(
                            questionID: viewModel.questionsWithChoices[viewModel.currentIndex].id,
                            homeworkID: viewModel.questionsWithChoices[viewModel.currentIndex].homeworkID,
                            selectedChoiceID: nil
                        )
                    }
                } else {
                    ScrollView(.vertical) {
                        ForEach(viewModel.questionsWithChoices) { questionWithChoices in
                            QuestionAndChoicesItemView(
                                questionAndChoices: questionWithChoices,
                                mode: .review,
                                selectedChoiceIDFromServer: viewModel.questionIDAndSelectedChoiceID[questionWithChoices.id]
                            )
                        }
                    }
                    .task {
                        await viewModel.loadAnswersForReview(homeworkID: homeworkID)
                    }
                }
            }
            
        }
        .navigationTitle(mode == .answering ? "質問一覧" : "回答履歴")
        .navigationBarBackButtonHidden(mode == .answering)
        .task {
            await viewModel.loadALlQuestionsWithChoices(homeworkID: homeworkID)
        }
        .toast(isPresenting: $viewModel.showError) {
            AlertToast(
                displayMode: .banner(.slide),
                type: .error(.red),
                title: "エラーが発生しました",
                subTitle: viewModel.errorMessage,
            )
        }
    }
}

#Preview {
    NavigationStack {
        QuestionsView(
            authenticationRepository: TestAuthenticationRepository(),
            questionsWithChoicesRepository: TestQuestionsWithChoicesRepository(),
            answerRepository: TestAnswerRepository(),
            homeworkID: "",
            mode: .review)
    }
}
