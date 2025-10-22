//
//  TestUserRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/22.
//

import Foundation

class TestUserRepository: UserDataRepository {
    func saveUserData(userData: UserData) async throws {
        return
    }
    
    func fetchUserData(userID: String) async throws -> UserData {
        return .getDummy()
    }
    
    func updateFCMToken(userID: String, fcmToken: String) async throws {
        return
    }
}
