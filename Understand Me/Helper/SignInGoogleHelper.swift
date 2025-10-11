//
//  SignInGoogleHelper.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//


import Foundation
import GoogleSignIn
import GoogleSignInSwift

final class SignInGoogleHelper {

    @MainActor
    func signIn()async throws -> Token {
        guard let topVC = Utilities.shared.topViewController()else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let acessToken: String = gidSignInResult.user.accessToken.tokenString
        let name: String? = gidSignInResult.user.profile?.name
        let email: String? = gidSignInResult.user.profile?.email
        
        let tokens = Token(idToken: idToken, accessToken: acessToken)
        
        return tokens
    }
}


final class Utilities {
    
    static let shared = Utilities()
    private init() {}
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
        
    }
    
}
