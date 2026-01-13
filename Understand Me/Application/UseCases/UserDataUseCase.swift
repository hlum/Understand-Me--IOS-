//
//  UserDataUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation
import OSLog

class UserDataUseCase {
    private let userDataRepository: UserDataRepository
    private let fcmTokenRepository: FCMTokenRepository
    private let deviceManager = DeviceManager.shared
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "UseCase")
    
    init(
        userDataRepository: UserDataRepository,
        fcmTokenRepository: FCMTokenRepository
    ) {
        self.userDataRepository = userDataRepository
        self.fcmTokenRepository = fcmTokenRepository
    }
    
    
    
    func saveUserDataIfNotExist(userData: UserData) async throws {
        
        let userFromDB = try? await userDataRepository.fetchUserData(userID: userData.id)
        
        if userFromDB != nil {
            logger.info("UserDataはすでに保存されています。")
            return
        }
        
        try await userDataRepository.saveUserData(userData: userData)
    }
    
    
    @concurrent
    func deleteUserData(userID: String) async throws {
        try await userDataRepository.deleteUserData(userID: userID)
    }
    
    
    
    func fetchUserData(userID: String) async throws -> UserData {
        try await userDataRepository.fetchUserData(userID: userID)
    }
    
    
    
    func updateFCMToken(userID: String, fcmToken: String) async throws {
        let deviceID = deviceManager.getDeviceID()
        let deviceType = deviceManager.getDeviceType()
        
        try await fcmTokenRepository.saveOrUpdateToken(userID: userID, deviceID: deviceID, deviceType: deviceType, fcmToken: fcmToken)
    }
    
    func deleteFCMToken(userID: String) async throws {
        let deviceID = deviceManager.getDeviceID()
        
        try await fcmTokenRepository.deleteFcmToken(userID: userID, deviceID: deviceID)
    }
}
