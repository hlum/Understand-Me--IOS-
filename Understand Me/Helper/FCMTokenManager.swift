//
//  FCMTokenManager.swift
//  Understand Me
//
//  Created by GitHub Copilot on 2025/10/28.
//

import Foundation
import FirebaseMessaging

class FCMTokenManager {
    static let shared = FCMTokenManager()
    
    private init() {}
    
    /// Get the current FCM token
    func getFCMToken() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let token = token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: FCMTokenError.tokenNotAvailable)
                }
            }
        }
    }
    
    /// Update FCM token to the server
    func updateFCMTokenToServer(userID: String, userDataUseCase: UserDataUseCase) async {
        do {
            let token = try await getFCMToken()
            try await userDataUseCase.updateFCMToken(userID: userID, fcmToken: token)
            print("FCMトークンが正常に更新されました: \(token)")
        } catch {
            print("FCMトークンの更新に失敗しました: \(error.localizedDescription)")
        }
    }
}

enum FCMTokenError: Error {
    case tokenNotAvailable
    
    var localizedDescription: String {
        switch self {
        case .tokenNotAvailable:
            return "FCMトークンが取得できませんでした"
        }
    }
}
