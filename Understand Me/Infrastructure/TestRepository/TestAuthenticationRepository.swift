//
//  TestAuthenticationRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/20.
//

import Foundation

class TestAuthenticationRepository: AuthenticationRepository {
    var currentUser: AuthDataResultModel? = nil
    
    func signInWithGoogle(token: Token) async throws -> AuthDataResultModel {
        currentUser = .dummy()
        guard let currentUser else {
            throw URLError(.badServerResponse)
        }
        return currentUser
    }
    
    func fetchCurrentUser() -> AuthDataResultModel? {
        return currentUser
    }
    
    func signOut() throws {
        currentUser = nil
    }
}
