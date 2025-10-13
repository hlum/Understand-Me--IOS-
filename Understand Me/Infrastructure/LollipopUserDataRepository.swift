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
    
    private let secretLoader = SecretLoader.shared
    
    
    func saveUserData(userData: UserData) async throws {
        let url = try makeURL("user/register.php")
        let body = try JSONEncoder().encode(userData)
        let request = try makeRequest(url: url, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw UserDataRepositoryError.InvalidResponseStatus
        }
    }
    
    
    
    func fetchUserData(userID: String) async throws -> UserData {
        let url = try makeURL("user/get_user.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "id", value: userID)]
        
        guard let finalURL = components?.url else {
            throw UserDataRepositoryError.InvalidURL
        }
        
        let request = try makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try decodeAPIResponse(from: data)
        
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
        let url = try makeURL("user/update_fcm_token.php")
        
        let bodyDict = [
            "user_id": userID,
            "fcm_token": fcmToken
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let request = try makeRequest(url: url, method: "POST", body: bodyData)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw UserDataRepositoryError.InvalidResponseStatus
        }
    }

    
    
    private func makeURL(_ path: String) throws -> URL {
        let base = secretLoader.fetchSecret(from: "Secrets", forKey: "endpoint")
        guard let baseURL = URL(string: base)?.appendingPathComponent(path) else {
            throw UserDataRepositoryError.InvalidURL
        }
        return baseURL
    }
    
    
    
    private func makeRequest(url: URL, method: String, body: Data? = nil) throws -> URLRequest {
        let apiKey = secretLoader.fetchSecret(from: "Secrets", forKey: "APIKEY")
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.httpBody = body
        return request
    }
    
    
    
    private func decodeAPIResponse(from data: Data) throws -> APIResponse {
        try JSONDecoder().decode(APIResponse.self, from: data)
    }
    
    
}
