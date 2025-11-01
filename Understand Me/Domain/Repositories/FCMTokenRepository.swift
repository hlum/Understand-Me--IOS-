//
//  FCMTokenRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/01.
//

import Foundation

protocol FCMTokenRepository {
    func saveOrUpdateToken(userID: String, deviceID: String, deviceType: String, fcmToken: String) async throws
}
