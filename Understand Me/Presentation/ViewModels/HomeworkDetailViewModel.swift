//
//  HomeworkDetailViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine
import OSLog


// Graph に表示する月ごとの平均点数
struct AverageResultPerMonth: Identifiable {
    let id: String = UUID().uuidString
    let month: Date
    let averageScore: Double
    
    init(month: Date, averageScore: Double) {
        self.month = month
        self.averageScore = averageScore
    }
    
    
    init(resultsOfOneMonth: [ResultData]) {
        self.month = resultsOfOneMonth.first?.evaluatedAt ?? Date()
        let totalScore = resultsOfOneMonth.reduce(0.0) { partialResult, result in
            partialResult + Double(result.score)
        }
        self.averageScore = totalScore / Double(resultsOfOneMonth.count)
    }
    
    
    static func getDummy() -> [AverageResultPerMonth] {
        let now = Date()
        let calendar = Calendar.current
        var dummyData: [AverageResultPerMonth] = []
        for i in 0..<12 {
            if let monthDate = calendar.date(byAdding: .month, value: -i, to: now) {
                let averageScore = Double.random(in: 60...100)
                let averageResult = AverageResultPerMonth(
                    month: monthDate,
                    averageScore: averageScore
                )
                dummyData.append(averageResult)
            }
        }
        
        return dummyData
        
    }
}

class HomeworkDetailViewModel: ObservableObject {
    @Published var homework: HomeworkWithStatus?
    @Published var classDetail: Class?
    @Published var homeworkLinkTxt: String = ""
    @Published var result: ResultData? = nil
    @Published var errorMessage: String = ""
    @Published var showErrorAlert: Bool = false
    @Published var showInputError: Bool = false
    @Published var inputErrorMessage: String = ""
    
    private let homeworkUseCase: HomeworkUseCase
    private let classUseCase: ClassUseCase
    private let projectUseCase: ProjectUseCase
    private let authenticationUseCase: AuthenticationUseCase
    private let resultUseCase: ResultUseCase
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    init(
        homeworkUseCase: HomeworkUseCase,
        classUseCase: ClassUseCase,
        projectUseCase: ProjectUseCase,
        authenticationUseCase: AuthenticationUseCase,
        resultUseCase: ResultUseCase
    ) {
        self.homeworkUseCase = homeworkUseCase
        self.classUseCase = classUseCase
        self.projectUseCase = projectUseCase
        self.authenticationUseCase = authenticationUseCase
        self.resultUseCase = resultUseCase
    }
    
    
    
    @MainActor
    func loadInfoOfHomework(homeworkID: String) async {
        await loadHomework(id: homeworkID)
        if let homework = self.homework {
            await loadClassDetail(classID: homework.classID)
        }
    }
    
    
    
    func uploadProject() async {
        inputErrorMessage = ""
        showInputError = false
        
        guard let _ = URL(string: homeworkLinkTxt) else {
            await showAlert(message: "URLの形式が不正です。正しいURLを入力してください。")
            logger.error("HomeworkDetailViewModel.uploadProject: URLの形式が不正です。")
            return
        }
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            await showInputError(message: "予期せぬエラーが発生しました。もう一度やり直してください。")
            logger.error("HomeworkDetailViewModel.uploadProject: ログインしているユーザーがいません。")
            return
        }
        
        guard let homework = homework else {
            await showInputError(message: "宿題の情報が見つかりません。")
            logger.error("HomeworkDetailViewModel.uploadProject: 宿題の情報がありません。")
            return
        }
        
        do {
            try await projectUseCase.uploadProject(
                userID: authDataResult.id,
                homeworkID: homework.id,
                githubURLString: homeworkLinkTxt
            )
        } catch let error as UseCaseErrors {
            await showInputError(message: error.localizedDescription)
        } catch {
            // unexpected errors
            await showInputError(message: "予期せぬエラーが発生しました。もう一度やり直してください。")
            logger.error("HomeworkDetailViewModel.uploadProject: \(error.localizedDescription)")
        }
    }
    
    
    
    func retryQuestionGeneration(homeworkID: String) async  {
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            await showAlert(message: "ログイン情報を取得できませんでした。")
            logger.error("HomeworkDetailViewModel.retryQuestionGeneration: ログインしているユーザーがいません。")
            return
        }
        
        do {
            try await homeworkUseCase.retryQuestionGeneration(homeworkID: homeworkID, studentID: authDataResult.id)
        } catch let error as LollipopError {
            await showAlert(message: error.errorDescription ?? "問題生成の再試行に失敗しました。")
            logger.error("HomeworkDetailViewModel.retryQuestionGeneration: \(error.debugDescription)")
        } catch {
            await showAlert(message: "問題生成の再試行に失敗しました。")
            logger.error("HomeworkDetailViewModel.retryQuestionGeneration: \(error.localizedDescription)")
        }
    }
    
    
    
    func cancelHomeworkSubmission(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            await showAlert(message: "ログイン情報を取得できませんでした。")
            logger.error("HomeworkDetailViewModel.cancelHomeworkSubmission: ログインしているユーザーがいません。")
            return
        }
        
        do {
            try await homeworkUseCase.cancelHomeworkSubmission(homeworkID: homeworkID, studentID: authDataResult.id)
        } catch let error as LollipopError {
            await showAlert(message: error.errorDescription ?? "宿題提出の取り消しに失敗しました。")
            logger.error("HomeworkDetailViewModel.cancelHomeworkSubmission: \(error.debugDescription)")
        } catch {
            await showAlert(message: "宿題提出の取り消しに失敗しました。")
            logger.error("HomeworkDetailViewModel.cancelHomeworkSubmission: \(error.localizedDescription)")
        }
    }
    
    
    
    
    @MainActor
    private func loadHomework(id: String) async {
        do {
            
            guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
                showAlert(message: "ログイン情報を取得できませんでした。")
                logger.error("HomeworkDetailViewModel.loadHomework: ログインしているユーザーがいません。")
                return
            }
            
            homework = try await homeworkUseCase.fetchHomework(id: id, studentID: authDataResult.id)
        } catch let error as LollipopError {
            showAlert(message: error.errorDescription ?? "宿題の取得に失敗しました。")
            logger.error("HomeworkDetailViewModel.loadHomework: \(error.debugDescription)")
        } catch {
            showAlert(message: "宿題の取得に失敗しました。")
            logger.error("HomeworkDetailViewModel.loadHomework: \(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    private func loadClassDetail(classID: String) async {
        do {
            self.classDetail = try await classUseCase.fetchClass(id: classID)
        } catch let error as LollipopError {
            showAlert(message: error.errorDescription ?? "クラス情報の取得に失敗しました。")
            logger.error("HomeworkDetailViewModel.loadClassDetail: \(error.debugDescription)")
        } catch {
            showAlert(message: "クラス情報の取得に失敗しました。")
            logger.error("HomeworkDetailViewModel.loadClassDetail: \(error.localizedDescription)")
        }
    }
    
    // TODO: Result should be nullable
    @MainActor
    func loadResult(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            showAlert(message: "ログイン情報を取得できませんでした。")
            logger.error("QuestionsViewModel.loadAnswersForReview: ログイン中のUserがありません。")
            return
        }

        do {
            self.result = try await resultUseCase.fetchResult(userID: authDataResult.id, homeworkID: homeworkID)
        } catch let error as LollipopError {
            showAlert(message: error.errorDescription ?? "結果の取得に失敗しました。")
            logger.error("QuestionsViewModel.loadResult: \(error.debugDescription)")
        } catch {
            showAlert(message: "結果の取得に失敗しました。")
            logger.error("QuestionsViewModel.loadResult: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func showAlert(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    @MainActor
    private func showInputError(message: String) {
        inputErrorMessage = message
        showInputError = true
    }
    
}

