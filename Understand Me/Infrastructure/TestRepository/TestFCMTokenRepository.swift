//
//  TestFCMTokenRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/01.
//

import Foundation

class TestFCMTokenRepository: FCMTokenRepository {
    
    
    func saveOrUpdateToken(userID: String, deviceID: String, deviceType: String, fcmToken: String) async throws {
        return
    }
    
    func deleteFcmToken(userID: String, deviceID: String) async throws {
        return
    }

}
