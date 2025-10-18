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
    
    private var authenticationUseCase: AuthenticationUseCase
    private var questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase
    
    init(
        authenticationUseCase: AuthenticationUseCase,
        questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase
    ) {
        self.authenticationUseCase = authenticationUseCase
        self.questionsWithChoicesUseCase = questionsWithChoicesUseCase
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
}

struct QuestionsView: View {
    @Environment(\.dismiss) var dismiss
        
    @StateObject private var viewModel = QuestionsViewModel(authenticationUseCase: AuthenticationUseCase(authenticationRepository: FirebaseAuthenticationRepository()), questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase(questionsWithChoicesRepository: LollipopQuestionsWithChoicesRepository()))
    
    var homeworkID: String
    
    var body: some View {
        VStack {
            if viewModel.questionsWithChoices.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                QuestionAndChoicesItemView(
                    questionAndChoices: viewModel.questionsWithChoices[viewModel.currentIndex],
                    isLastQuestion: viewModel.currentIndex == viewModel.questionsWithChoices.count - 1,
                    onClickNext: {
                        if viewModel.currentIndex < viewModel.questionsWithChoices.count - 1 {
                            withAnimation(.snappy) {
                                viewModel.currentIndex += 1
                            }
                        } else {
                            // Quiz 終了、前のViewに戻る
                            dismiss()

                        }
                        
                    })

            }
            
            Spacer()
        }
        .navigationTitle("質問一覧")
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
