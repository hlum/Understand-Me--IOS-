//
//  LogInViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation
import Combine
import OSLog

class LogInViewModel: ObservableObject {
    // Dependencies
    private let authenticationUseCase: AuthenticationUseCase
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    @Published var errorMessage: String = ""
    @Published var showErrorAlert: Bool = false
    
    
    @Published var isGoogleLoggingIn: Bool = false
    @Published var isAppleLoggingIn: Bool = false
    
    init(authenticationUseCase: AuthenticationUseCase) {
        self.authenticationUseCase = authenticationUseCase
    }
    
    
    func signInWithGoogle() async -> AuthDataResultModel? {
        isGoogleLoggingIn = true
        defer { isGoogleLoggingIn = false }
        do {
            return try await authenticationUseCase.signInWithGoogle()
        } catch {
            showErrorAlert(message: "ログイン失敗しました。もう一度お試しください。")
            logger.error("Login失敗。詳細: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func signInWithApple() async -> AuthDataResultModel? {
        isAppleLoggingIn = true
        defer { isAppleLoggingIn = false }
        do {
            return try await authenticationUseCase.signInWithApple()
        } catch  {
            showErrorAlert(message: "ログイン失敗しました。もう一度お試しください。")
            logger.error("Login失敗。詳細: \(error.localizedDescription)")
            return nil

        }
    }
    
    func fetchCurrentLoginUser() async -> AuthDataResultModel? {
        return await authenticationUseCase.fetchCurrentUser()
    }
    
    @MainActor
    private func showErrorAlert(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}
