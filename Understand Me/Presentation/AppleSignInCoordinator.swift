//
//  AppleSignIn.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/08.
//

import Foundation
import CryptoKit
import FirebaseAuth
import AuthenticationServices

struct AppleSignInResult {
    let idToken: String
    let rawNonce: String
    let fullName: PersonNameComponents?
}


class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    fileprivate var currentNonce: String?
    private var completion: ((Result<AppleSignInResult, Error>) -> Void)?

    func startSignInWithAppleFlow(
        completion: @escaping (Result<AppleSignInResult, Error>) -> Void
    ) {
        self.completion = completion
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
}

// MARK: Delegate callbacks
extension AppleSignInCoordinator {
    
    // Presentation context (where the Apple sign-in sheet appears)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? UIWindow()
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("IdentityTokenを取得できませんでした")
                return
            }
            
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("IdentityTokenを文字列に変換できませんでした")
                return
            }
            
            let appleSignInResult = AppleSignInResult(idToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            completion?(.success(appleSignInResult))
            
        }
    }
    
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        completion?(.failure(error))
    }
    

}


// MARK: Helper functions
extension AppleSignInCoordinator {
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
}
