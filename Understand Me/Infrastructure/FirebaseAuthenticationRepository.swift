//
//  FirebaseAuthenticationRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//

import Foundation
import FirebaseAuth

class FirebaseAuthenticationRepository: AuthenticationRepository {
    private let appleSignInCoordinator: AppleSignInCoordinator
    
    
    init(appleSignInCoordinator: AppleSignInCoordinator = AppleSignInCoordinator()) {
        self.appleSignInCoordinator = appleSignInCoordinator
    }
    
    
    func signInWithGoogle(token: Token) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: token.idToken, accessToken: token.accessToken)
        return try await signInWithCredential(credential: credential)
    }
    
    
    func signInWithApple() async throws -> AuthDataResultModel {
        
        try await withCheckedThrowingContinuation { continuation in
            appleSignInCoordinator.startSignInWithAppleFlow { result in
                
                switch result {
                          
                    case .success(let appleSignInResult):
                        let credential = OAuthProvider.appleCredential(
                            withIDToken: appleSignInResult.idToken,
                            rawNonce: appleSignInResult.rawNonce,
                            fullName: appleSignInResult.fullName
                        )
                        
                        Task {
                            let authData = try await self.signInWithCredential(credential: credential)
                            continuation.resume(returning: authData)
                        }
                        
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    func fetchCurrentUser() -> AuthDataResultModel? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return AuthDataResultModel(user: currentUser)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    private func signInWithCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
