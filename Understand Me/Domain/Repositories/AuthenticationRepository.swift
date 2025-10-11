//
//  AuthenticationRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//

import Foundation
import FirebaseAuth

protocol AuthenticationRepository {
    func signInWithGoogle(token: Token) async throws -> AuthDataResultModel
    func fetchCurrentUser() -> AuthDataResultModel?
    func signOut() throws
}
