//
//  ProfileViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//
import Foundation
import Combine
import SwiftUI
import OSLog

class ProfileViewModel: ObservableObject {
    @Published var userData: UserData?
    @Published var results: [ResultData] = []
    @Published var averageResultsPerMonth: [AverageResultPerMonth] = []
    @Published var averageScoreOfAllResults: Int = 0

    // グラフに表示するデータの年
    @Published var currentYearForGraph: Int = Calendar.current.component(.year, from: Date())
    
    
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private let authenticationUseCase: AuthenticationUseCase
    private let userDataUseCase: UserDataUseCase
    private let resultUseCase: ResultUseCase
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    init(
        authenticationUseCase: AuthenticationUseCase,
        userDataUseCase: UserDataUseCase,
        resultUseCase: ResultUseCase
    ) {
        self.authenticationUseCase = authenticationUseCase
        self.userDataUseCase = userDataUseCase
        self.resultUseCase = resultUseCase
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
            // TODO: UserにAlertで知らせる
            logger.error("ProfileViewModel.loadUserData: UserDataの取得に失敗しました。")
        }
    }
    
    
    
    @MainActor
    func loadResults() async {
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        
        do {
            self.results = try await resultUseCase.fetchResults(userID: authDataResult.id, year: currentYearForGraph)
        } catch {
            // TODO: UserにAlertで知らせる
            logger.error("ProfileViewModel.loadResults: Resultの取得に失敗しました。")
        }
    }
    
    
    @MainActor
    func loadAverageScoreOfAllResults() {
        guard !results.isEmpty else {
            return
        }
        
        let totalScore = results.reduce(0) { partialResult, result in
            partialResult + result.score
        }
        
        self.averageScoreOfAllResults = totalScore / results.count
    }
    
    
    @MainActor
    func loadAverageResultsPerMonth() {
        guard !results.isEmpty else {
            return
        }
        
        withAnimation(.easeInOut) {
            self.averageResultsPerMonth = resultUseCase.calculateAverageResultsPerMonth(results: results, year: currentYearForGraph)
        }
    }
    
    
    func signOut() async {
        do {
            // FCMトークンを削除
            if let authDataResult = await authenticationUseCase.fetchCurrentUser() {
                try? await userDataUseCase.deleteFCMToken(userID: authDataResult.id)
            }
            
            // ログアウト
            try authenticationUseCase.signOut()
        } catch {
            await showErrorAlert(message: error.localizedDescription)
        }
    }
    
    @MainActor
    private func showErrorAlert(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
