//
//  UserDataRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation
import OSLog



class LollipopUserDataRepository: UserDataRepository {
    
    private let lollipopAPIUtility: LollipopAPIUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")
    
    func saveUserData(userData: UserData) async throws {
        let url = try lollipopAPIUtility.makeURL("user/register.php")
        let body = try JSONEncoder().encode(userData)
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response: APIResponse<EmptyResponse> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
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
        
        let response: APIResponse<UserData> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)

        guard let results = response.dataString,
              let result = results.first else {
            throw URLError(.badServerResponse)
        }

       return result
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
        
        let response: APIResponse<EmptyResponse> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
        logger.info("FCMトークンの更新に成功: userID=\(userID)")
    }
    
    
    func deleteUserData(userID: String) async throws {
        let url = try lollipopAPIUtility.makeURL("user/delete_user.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "id", value: userID)]
        
        guard let finalURL = components?.url else {
            throw LollipopError.InvalidURL
        }

        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "DELETE")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<EmptyResponse> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
        logger.info("Userデータの削除に成功: userID=\(userID)")
    }

}
