//
//  ClassHomeworkViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine
import OSLog

class ClassHomeworkViewModel: ObservableObject {
    @Published var homeworks: [HomeworkWithStatus] = []
    @Published var classInfo: Class? = nil
    @Published var filteredHomeworks: [HomeworkWithStatus] = []
    @Published var selectedFilterOption: HomeworkFilterOption = .all
    @Published var isLoading: Bool = false
    @Published var isFiltering: Bool = false
    
    private var homeworkUseCase: HomeworkUseCase
    private var authenticationUseCase: AuthenticationUseCase
    private var classUseCase: ClassUseCase
    private var classID: String
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    
    init(
        homeworkUseCase: HomeworkUseCase,
        authenticationUseCase: AuthenticationUseCase,
        classUseCase: ClassUseCase,
        classID: String
    ) {
        self.homeworkUseCase = homeworkUseCase
        self.authenticationUseCase = authenticationUseCase
        self.classUseCase = classUseCase
        self.classID = classID
    }
    
    @MainActor
    func loadClassInfos() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.classInfo = try await classUseCase.fetchClass(id: classID)
        } catch {
            logger.error("ClassHomeworkViewModel.loadClassInfos: クラス情報の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    func loadHomeworks(classID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("ClassHomeworkViewModel.loadHomeworks: ログインしているユーザーがいません。")
            return
        }
        
        do {
            self.homeworks = try await homeworkUseCase.fetchHomeworks(studentID: authDataResult.id, classID: classID)
        } catch {
            logger.error("ClassHomeworkViewModel.loadHomeworks: 宿題の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func filterHomeworks() async {
        isFiltering = true
        defer { isFiltering = false }
        
        let homeworks = self.homeworks
        let filter = selectedFilterOption
        
        filteredHomeworks = await performFilterHomeworks(homeworks: homeworks, filter: filter)
    }
    
    @concurrent
    private func performFilterHomeworks(homeworks: [HomeworkWithStatus], filter: HomeworkFilterOption) async -> [HomeworkWithStatus] {
        switch filter {
        case .all:
            return homeworks.sorted { $0.createdAt > $1.createdAt }
        case .state(let state):
            if state == .notAssigned {
                return homeworks
                        .filter { $0.submissionState == state }
                        .sorted {
                            switch ($0.dueDate, $1.dueDate) {
                                case let (d1?, d2?):  return d1 < d2     // 両方 non-nil → 直接比較
                                case (nil, nil):      return false       // 両方 nil → 順番変えない
                                case (nil, _):        return false       // 左が nil → 後ろへ
                                case (_, nil):        return true        // 右が nil → 左を前へ
                            }
                        }
            }
            return homeworks.filter { $0.submissionState == state }
        }
    }
}
