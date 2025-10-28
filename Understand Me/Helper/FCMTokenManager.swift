//
//  FCMTokenManager.swift
//  Understand Me
//
//  Created by GitHub Copilot on 2025/10/28.
//

import Foundation
import FirebaseMessaging
import OSLog

extension Notification.Name {
    static let fcmTokenRefreshed = Notification.Name("FCMTokenRefreshed")
}

class FCMTokenManager {
    static let shared = FCMTokenManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Helper")
    
    private init() {}
    
    /// 新しいFCMトークンを非同期に取得する
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
    
    /// FCMトークンをサーバーに更新する
    func updateFCMTokenToServer(userID: String, userDataUseCase: UserDataUseCase) async {
        do {
            let token = try await getFCMToken()
            try await userDataUseCase.updateFCMToken(userID: userID, fcmToken: token)
            logger.info("FCMトークンが正常に更新されました: \(token)")
        } catch {
            logger.error("FCMトークンの更新に失敗しました: \(error.localizedDescription)")
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
