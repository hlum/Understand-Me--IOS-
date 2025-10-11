//
//  UserDataUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

class UserDataUseCase {
    private let userDataRepository: UserDataRepository
    
    init(userDataRepository: UserDataRepository) {
        self.userDataRepository = userDataRepository
    }
    
    
    
    func saveUserDataIfNotExist(userData: UserData) async throws {
        
        let userFromDB = try? await userDataRepository.fetchUserData(userID: userData.id)
        
        if userFromDB != nil {
            print("UserDataはすでに保存されています。")
            return
        }
        
        try await userDataRepository.saveUserData(userData: userData)
    }
    
    
    
    func fetchUserData(userID: String) async throws -> UserData {
        try await userDataRepository.fetchUserData(userID: userID)
    }
    
    
    
    func updateFCMToken(userID: String, fcmToken: String) async throws {
        try await userDataRepository.updateFCMToken(userID: userID, fcmToken: fcmToken)
    }
}
