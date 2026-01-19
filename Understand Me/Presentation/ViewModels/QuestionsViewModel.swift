//
//  QuestionsViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/27.
//


import Combine
import OSLog

class QuestionsViewModel: ObservableObject {
    @Published var questionsWithChoices: [QuestionWithChoices] = []
    @Published var currentIndex = 0
    @Published var questionIDAndSelectedChoiceID: [String: String] = [:] // questionID: selectedChoiceID
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    private var authenticationUseCase: AuthenticationUseCase
    private var questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase
    private var answerUseCase: AnswerUseCase
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
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
        isLoading = true
        defer { isLoading = false }

        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("QuestionsViewModel.loadAllQuestionsWithChoices: ログイン中のUserがありません。")
            return
        }

        do {

            self.questionsWithChoices = try await questionsWithChoicesUseCase.fetchAll(
                homeworkID: homeworkID,
                userID: authDataResult.id
            )

        } catch is CancellationError {
            // Task was cancelled, this is expected behavior
            logger.debug("QuestionsViewModel.loadAllQuestionsWithChoices: cancelled")
        } catch let urlError as URLError where urlError.code == .cancelled {
            logger.debug("QuestionsViewModel.loadAllQuestionsWithChoices: network request cancelled")
        } catch {
            logger.error("QuestionsViewModel.loadAllQuestionsWithChoices: \(error.localizedDescription)")
            errorMessage = "質問の読み込みに失敗しました。"
            showError = true
        }
    }
    
    
    
    func postAnswer(questionID: String, homeworkID: String, selectedChoiceID: String?) async {
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
            let totalQuestions = questionsWithChoices.count
            try await answerUseCase.addAnswer(answer: answer, homeworkID: homeworkID, totalQuestions: totalQuestions)
        } catch {
            logger.error("QuestionsViewModel.postAnswer: \(error.localizedDescription)")
            errorMessage = "回答の送信に失敗しました: \n \(error.localizedDescription)"
            showError = true
        }
    }
    
    
    
    func loadAnswersForReview(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("QuestionsViewModel.loadAnswersForReview: ログイン中のUserがありません。")
            return
        }
        do {
            let answers = try await answerUseCase.fetchAnswers(homeworkID: homeworkID, userID: authDataResult.id)
            answers.forEach { answer in
                self.questionIDAndSelectedChoiceID[answer.questionID] = answer.selectedChoiceID
            }
        } catch {
            logger.error("QuestionsViewModel.loadAnswersForReview: \(error.localizedDescription)")
            errorMessage = "回答履歴の読み込みに失敗しました。 \(error.localizedDescription)"
            showError = true
        }
    }
}
