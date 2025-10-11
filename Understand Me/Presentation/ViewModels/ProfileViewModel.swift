//
//  ProfileViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//
import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private let authenticationUseCase: AuthenticationUseCase
    
    init(authenticationUseCase: AuthenticationUseCase) {
        self.authenticationUseCase = authenticationUseCase
    }
    
    func signOut() {
        do {
            try authenticationUseCase.signOut()
        } catch {
            showErrorAlert(message: errorMessage.description)
        }
    }
    
    @MainActor
    private func showErrorAlert(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
