//
//  LollipopFCMTokenRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/01.
//

import Foundation
import OSLog

class LollipopFCMTokenRepository: FCMTokenRepository {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")
    
    private let lollipopUtility = LollipopAPIUtility()
    
    
    func saveOrUpdateToken(
        userID: String,
        deviceID: String,
        deviceType: String,
        fcmToken: String
    ) async throws {
        let url = try lollipopUtility.makeURL("user/update_fcm_token.php")
        let body = try JSONEncoder().encode([
            "user_id": userID,
            "device_id": deviceID,
            "device_type": deviceType,
            "fcm_token": fcmToken
        ])
        let request = try lollipopUtility.makeRequest(url: url, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try lollipopUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            logger.error("ResponseのStatusがsuccessではありません。エラー詳細: \(response.message)")
            throw LollipopError.InvalidResponseStatus
        }
    }
    
    func deleteFcmToken(userID: String, deviceID: String) async throws {
        let url = try lollipopUtility.makeURL("user/delete_fcm_token.php")
        let body = try JSONEncoder().encode([
            "user_id": userID,
            "device_id": deviceID
        ])
        let request = try lollipopUtility.makeRequest(url: url, method: "DELETE", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try lollipopUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            logger.error("ResponseのStatusがsuccessではありません。エラー詳細: \(response.message)")
            throw LollipopError.InvalidResponseStatus
        }
    }
    
}
