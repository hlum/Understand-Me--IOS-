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
    
    /// ユーザー向けのエラーメッセージ
    var errorDescription: String? {
        switch self {
        case .validation(let message):
            // バリデーションエラーはサーバーからのメッセージをそのまま表示
            return message
        case .auth:
            return "ログインの有効期限が切れました。再度ログインしてください。"
        case .forbidden:
            return "この操作を行う権限がありません。"
        case .notFound:
            return "お探しの情報が見つかりませんでした。"
        case .server:
            return "サーバーで問題が発生しました。しばらくしてからもう一度お試しください。"
        case .invalidResponse:
            return "予期しないエラーが発生しました。もう一度お試しください。"
        case .InvalidURL:
            return "接続先のURLが正しくありません。"
        case .NoDataFoundInResponse:
            return "データの取得に失敗しました。"
        case .UserNotFound:
            return "ユーザー情報が見つかりませんでした。"
        }
    }
    
    /// デバッグ用の詳細なエラー情報
    var debugDescription: String {
        switch self {
        case .validation(let message):
            return "バリデーションエラー: \(message)"
        case .auth:
            return "認証エラー: 認証情報が無効または期限切れ"
        case .forbidden:
            return "アクセス拒否: リソースへのアクセス権限なし"
        case .notFound:
            return "リソース未検出: 要求されたリソースが存在しない"
        case .server:
            return "サーバーエラー: サーバー側で内部エラーが発生"
        case .invalidResponse:
            return "不正なレスポンス: 予期しないレスポンス形式"
        case .InvalidURL:
            return "無効なURL: URLの構築に失敗"
        case .NoDataFoundInResponse:
            return "データ不在: レスポンスにdataフィールドが存在しない"
        case .UserNotFound:
            return "ユーザー未検出: 指定されたIDのユーザーが見つからない"
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
        logger.info("ユーザーデータの保存に成功: userID=\(userData.id)")
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
                logger.info("ユーザーデータの取得に成功: userID=\(userID)")
                return userData
            }
            logger.error("ユーザーデータが配列に含まれていません: userID=\(userID)")
            throw LollipopError.UserNotFound
        } catch let error as LollipopError {
            logger.error("ユーザーデータの取得に失敗: \(error.debugDescription)")
            throw error
        } catch {
            logger.error("ユーザーデータのDecodeに失敗: \(error.localizedDescription)")
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
        logger.info("FCMトークンの更新に成功: userID=\(userID)")
    }

}
