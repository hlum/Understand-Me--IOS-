//
//  UserDataRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

enum UserDataRepositoryError: LocalizedError {
    case InvalidURL
    case NoDataFoundInResponse
    case InvalidResponseStatus
    case UserNotFound
    
    var errorDescription: String? {
        switch self {
        case .InvalidURL:
            return "URL が無効です。"
        case .NoDataFoundInResponse:
            return "データが返っていません。"
        case .InvalidResponseStatus:
            return "ResponseのStatusがsuccessではありません。"
        case .UserNotFound:
            return "指定されたIDのユーザーが見つかりませんでした。"
        }
    }
}

class LollipopUserDataRepository: UserDataRepository {
    
    private let lollipopAPIUtility: LollipopAPIUtility = LollipopAPIUtility()
    
    func saveUserData(userData: UserData) async throws {
        let url = try lollipopAPIUtility.makeURL("user/register.php")
        let body = try JSONEncoder().encode(userData)
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw UserDataRepositoryError.InvalidResponseStatus
        }
    }
    
    
    
    func fetchUserData(userID: String) async throws -> UserData {
        let url = try lollipopAPIUtility.makeURL("user/get_user.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "id", value: userID)]
        
        guard let finalURL = components?.url else {
            throw UserDataRepositoryError.InvalidURL
        }
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            
            if response.message.lowercased().contains("ユーザーが存在しません") {
                throw UserDataRepositoryError.UserNotFound
            }
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw UserDataRepositoryError.InvalidResponseStatus
        }

        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw UserDataRepositoryError.NoDataFoundInResponse
        }

        do {
            let userDatas = try JSONDecoder().decode([UserData].self, from: jsonData)
            if let userData = userDatas.first {
                return userData
            }
            throw UserDataRepositoryError.UserNotFound
        } catch {
            print("UserDataのDecodeに失敗。失敗: \(error.localizedDescription)")
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
        
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "POST", body: bodyData)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw UserDataRepositoryError.InvalidResponseStatus
        }
    }

}
