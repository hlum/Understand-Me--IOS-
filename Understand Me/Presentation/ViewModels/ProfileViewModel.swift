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
        } catch let error as LollipopError {
            showErrorAlert(message: error.errorDescription ?? "ユーザーデータの取得に失敗しました。")
            logger.error("ProfileViewModel.loadUserData: \(error.debugDescription)")
        } catch {
            showErrorAlert(message: "ユーザーデータの取得に失敗しました。")
            logger.error("ProfileViewModel.loadUserData: \(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    func loadResults() async {
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        
        do {
            self.results = try await resultUseCase.fetchResults(userID: authDataResult.id)
        } catch let error as LollipopError {
            showErrorAlert(message: error.errorDescription ?? "結果の取得に失敗しました。")
            logger.error("ProfileViewModel.loadResults: \(error.debugDescription)")
        } catch {
            showErrorAlert(message: "結果の取得に失敗しました。")
            logger.error("ProfileViewModel.loadResults: \(error.localizedDescription)")
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
                do {
                    try await userDataUseCase.deleteFCMToken(userID: authDataResult.id)
                } catch let error as LollipopError {
                    logger.warning("FCMトークンの削除に失敗（ログアウトは続行）: \(error.debugDescription)")
                } catch {
                    logger.warning("FCMトークンの削除に失敗（ログアウトは続行）: \(error.localizedDescription)")
                }
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
