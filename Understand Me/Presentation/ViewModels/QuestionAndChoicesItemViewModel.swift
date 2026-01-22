//
//  QuestionAndChoicesItemViewModel.swift
//  Understand Me
//
//  Created by アウン on 2026/01/20.
//


import Combine
import OSLog
import Foundation

class QuestionAndChoicesItemViewModel: ObservableObject {
    @Published var selectedChoiceID: String? = nil
    @Published var correctChoiceID: String? = nil
    @Published var showCorrectAnswer: Bool = false
    
    @Published var isArcTimerRunning: Bool = false

    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    
    @Published var submittingAnswer: Bool = false
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
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
    func postAnswer(questionCount: Int, questionID: String, homeworkID: String, selectedChoiceID: String?) async {
        
        submittingAnswer = true
        defer { submittingAnswer = false }

        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("QuestionsViewModel.postAnswer: ログイン中のUserがありません。")
            return
        }
        
        let answer = Answer(
            questionID: questionID,
            userID: authDataResult.id,
            selectedChoiceID: selectedChoiceID
        )
        
        do {
            correctChoiceID = try await answerUseCase.addAnswer(answer: answer, homeworkID: homeworkID, totalQuestions: questionCount)
        } catch let urlError as URLError where urlError.code == .cancelled {
            logger.debug("QuestionAndChoicesItemViewModel.postAnswer: network request cancelled")
        } catch {
            logger.error("QuestionAndChoicesItemViewModel.postAnswer: \(error.localizedDescription)")
            errorMessage = "回答の送信に失敗しました。"
            showError = true
        }

    }
    
    
    // Review Mode 用の正解の選択肢を取得
    @MainActor
    func loadCorrectChoice(homeworkID: String, questionID: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            correctChoiceID = try await questionsWithChoicesUseCase.fetchCorrectChoice(homeworkID: homeworkID, questionID: questionID).id
        } catch {
            logger.error("QuestionAndChoicesItemViewModel.loadCorrectChoice: \(error.localizedDescription)")
            errorMessage = "回答の送信に失敗しました。"
            showError = true
        }
    }
}
