//
//  AuthenticationUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//

import Foundation

class AuthenticationUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func signInWithGoogle() async throws -> AuthDataResultModel {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        return try await authenticationRepository.signInWithGoogle(token: tokens)
    }
    
    
    func signInWithApple() async throws -> AuthDataResultModel {
        try await authenticationRepository.signInWithApple()
    }
    
    func fetchCurrentUser() async -> AuthDataResultModel? {
        return authenticationRepository.fetchCurrentUser()
    }
    
    func signOut() throws {
        try authenticationRepository.signOut()
    }
}
