//
//  UserDataRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation
import OSLog

enum LollipopError: LocalizedError {
    case validation(String)
    case auth
    case forbidden
    case notFound
    case server
    case invalidResponse
    case InvalidURL
    case NoDataFoundInResponse
    case UserNotFound
    
    var errorDescription: String? {
        switch self {
        case .validation(let message):
            return "バリデーションエラー: \(message)"
        case .auth:
            return "認証エラー: ログインが必要です。"
        case .forbidden:
            return "アクセス権限がありません。"
        case .notFound:
            return "リソースが見つかりませんでした。"
        case .server:
            return "サーバーエラーが発生しました。"
        case .invalidResponse:
            return "不正なレスポンスです。"
        case .InvalidURL:
            return "URL が無効です。"
        case .NoDataFoundInResponse:
            return "データが返っていません。"
        case .UserNotFound:
            return "指定されたIDのユーザーが見つかりませんでした。"
        }
    }
}

class LollipopUserDataRepository: UserDataRepository {
    
    private let lollipopAPIUtility: LollipopAPIUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")
    
    func saveUserData(userData: UserData) async throws {
        let url = try lollipopAPIUtility.makeURL("user/register.php")
        let body = try JSONEncoder().encode(userData)
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
    }
    
    
    
    func fetchUserData(userID: String) async throws -> UserData {
        let url = try lollipopAPIUtility.makeURL("user/get_user.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "id", value: userID)]
        
        guard let finalURL = components?.url else {
            throw LollipopError.InvalidURL
        }
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)

        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw LollipopError.NoDataFoundInResponse
        }

        do {
            let userDatas = try JSONDecoder().decode([UserData].self, from: jsonData)
            if let userData = userDatas.first {
                return userData
            }
            throw LollipopError.UserNotFound
        } catch {
            logger.error("UserDataのDecodeに失敗。失敗: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    
    func updateFCMToken(userID: String, fcmToken: String) async throws {
        let url = try lollipopAPIUtility.makeURL("user/update_fcm_token.php")
        
        let bodyDict = [
            "user_id": userID,
            "fcm_token": fcmToken
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "UPDATE", body: bodyData)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
    }

}
