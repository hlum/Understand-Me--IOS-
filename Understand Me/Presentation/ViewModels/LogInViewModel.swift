//
//  LogInViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation
import Combine

class LogInViewModel: ObservableObject {
    // Dependencies
    private let authenticationUseCase: AuthenticationUseCase
    
    @Published var errorMessage: String = ""
    @Published var showErrorAlert: Bool = false
    
    init(authenticationUseCase: AuthenticationUseCase) {
        self.authenticationUseCase = authenticationUseCase
    }
    
    
    func signInWithGoogle() async -> AuthDataResultModel? {
        do {
            return try await authenticationUseCase.signIn()
        } catch {
            showErrorAlert(message: "ログイン失敗しました。もう一度お試しください。")
            print("Login失敗。詳細: \(error.localizedDescription)")
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
