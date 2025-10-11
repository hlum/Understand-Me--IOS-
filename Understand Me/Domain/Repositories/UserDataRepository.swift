//
//  UserDataRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

protocol UserDataRepository {
    func saveUserData(userData: UserData) async throws
    func fetchUserData(userID: String) async throws
    func updateFCMToken(userID: String, fcmToken: String) async throws
}
