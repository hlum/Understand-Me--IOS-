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
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    
    
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
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        
        do {
            self.userData = try await userDataUseCase.fetchUserData(userID: authDataResult.id)
        } catch {
            logger.error("HomeViewModel.loadUserData(): UserDataの取得に失敗しました。")
            errorMessage = "ユーザーデータの読み込みに失敗しました"
            showError = true
        }
    }
    
    
    
    @MainActor
    func loadHomeworks() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        do {
            let homeworks = try await homeworkUseCase.fetchHomeworksNearDeadline(studentID: authDataResult.id)
            
            self.homeworks = homeworks
            
        } catch {
            logger.error("HomeViewModel.loadHomeworks(): 宿題の取得に失敗しました。")
            errorMessage = "課題の読み込みに失敗しました"
            showError = true
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
            errorMessage = "科目の読み込みに失敗しました"
            showError = true
        }

    }
}
