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
        guard let _ = URL(string: homeworkLinkTxt) else {
            // TODO: USER にAlertで知らせる
            logger.error("HomeworkDetailViewModel.uploadProject: URLの形式が不正です。")
            return
        }
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("HomeworkDetailViewModel.uploadProject: ログインしているユーザーがいません。")
            return
        }
        
        guard let homework = homework else {
            logger.error("HomeworkDetailViewModel.uploadProject: 宿題の情報がありません。")
            return
        }
        
        do {
            try await projectUseCase.uploadProject(
                userID: authDataResult.id,
                homeworkID: homework.id,
                githubURLString: homeworkLinkTxt
            )
        } catch {
            // TODO: Alert the user and impl retry methods
            logger.error("HomeworkDetailViewModel.uploadProject: プロジェクトのアップロードに失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    func retryQuestionGeneration(homeworkID: String) async  {
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("HomeworkDetailViewModel.retryQuestionGeneration: ログインしているユーザーがいません。")
            return
        }
        
        do {
            try await homeworkUseCase.retryQuestionGeneration(homeworkID: homeworkID, studentID: authDataResult.id)
        } catch {
            // TODO: Alert the user
            logger.error("HomeworkDetailViewModel.retryQuestionGeneration: リトライ失敗.\(error.localizedDescription)")
        }
    }
    
    
    
    func cancelHomeworkSubmission(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("HomeworkDetailViewModel.cancelHomeworkSubmission: ログインしているユーザーがいません。")
            return
        }
        
        do {
            try await homeworkUseCase.cancelHomeworkSubmission(homeworkID: homeworkID, studentID: authDataResult.id)
        } catch {
            // TODO: Alert the user
            logger.error("HomeworkDetailViewModel.cancelHomeworkSubmission: 取り消し失敗.\(error.localizedDescription)")
        }
    }
    
    
    
    
    @MainActor
    private func loadHomework(id: String) async {
        do {
            
            guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
                logger.error("HomeworkDetailViewModel.loadHomework: ログインしているユーザーがいません。")
                return
            }
            
            homework = try await homeworkUseCase.fetchHomework(id: id, studentID: authDataResult.id)
        } catch {
            logger.error("HomeworkDetailViewModel.loadHomework: 宿題の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    private func loadClassDetail(classID: String) async {
        do {
            self.classDetail = try await classUseCase.fetchClass(id: classID)
        } catch {
            logger.error("HomeworkDetailViewModel.loadClassDetail: クラス情報の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func loadResult(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("QuestionsViewModel.loadAnswersForReview: ログイン中のUserがありません。")
            return
        }

        do {
            self.result = try await resultUseCase.fetchResult(userID: authDataResult.id, homeworkID: homeworkID)
        } catch {
            // TODO: Show error to the user
            logger.error("QuestionsViewModel.loadResult: \(error.localizedDescription)")
        }
    }

    
}

