//
//  HomeViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/30.
//


import Combine
import OSLog



class HomeViewModel: ObservableObject {
    private let userDataUseCase: UserDataUseCase
    private let authenticationUseCase: AuthenticationUseCase
    private let homeworkUseCase: HomeworkUseCase
    private let classUseCase: ClassUseCase
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    @Published var userData: UserData? = nil
    @Published var homeworks: [HomeworkWithStatus] = []
    @Published var classes: [Class] = []
    @Published var isLoading: Bool = false
    
    
    init(
        authenticationUseCase: AuthenticationUseCase,
        userDataUseCase: UserDataUseCase,
        homeworkUseCase: HomeworkUseCase,
        classUseCase: ClassUseCase
    ) {
        self.userDataUseCase = userDataUseCase
        self.authenticationUseCase = authenticationUseCase
        self.homeworkUseCase = homeworkUseCase
        self.classUseCase = classUseCase
    }
    
    
    
    @MainActor
    func loadUserData() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        
        do {
            self.userData = try await userDataUseCase.fetchUserData(userID: authDataResult.id)
        } catch {
            // TODO: UserにAlertで知らせる
            logger.error("HomeViewModel.loadUserData(): UserDataの取得に失敗しました。")
        }
    }
    
    
    
    @MainActor
    func loadHomeworks() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        do {
            var homeworks = try await homeworkUseCase.fetchHomeworks(studentID: authDataResult.id)
            
            // 1. Filter (.completed じゃないものだけ)
            homeworks = homeworks.filter { $0.submissionState != .completed }
            
            
            // 2. Sort: dueDate(昇順),
            //    submissionStateの順に並び替え(.notAssigned, .failed, .questionGenerated, .generatingQuestions)
            homeworks.sort { lhs, rhs in
                // dueDateのUnwarp
                let lhsDate = lhs.dueDate ?? .distantFuture
                let rhsDate = rhs.dueDate ?? .distantFuture
                
                
                if lhsDate != rhsDate {
                    return lhsDate < rhsDate
                } else {
                    
                    // submissionStateの優先順位を定義
                    let submissionStatePriority: [HomeworkState: Int] = [
                        .notAssigned: 0,
                        .failed: 1,
                        .questionGenerated: 2,
                        .generatingQuestions: 3,
                    ]
                    
                    
                    return (submissionStatePriority[lhs.submissionState] ?? Int.max < submissionStatePriority[rhs.submissionState] ?? Int.max)
                }
            }
            
            
            self.homeworks = homeworks
            
        } catch {
            logger.error("HomeViewModel.loadHomeworks(): 宿題の取得に失敗しました。")
        }
    }
    
    
    
    @MainActor
    func loadClasses() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        do {
            self.classes = try await classUseCase.fetchClassList(studentID: authDataResult.id)
        } catch {
            logger.error("HomeViewModel.loadClasses(): クラスの取得に失敗しました。")
        }
        
    }
}
