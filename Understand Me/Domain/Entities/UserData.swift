//
//  UserData.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

struct UserData: Codable {
    let id: String
    let email: String
    let fcmToken: String?
    let photoURL: String?
    
    init(id: String, email: String, fcmToken: String?, photoURL: String?) {
        self.id = id
        self.email = email
        self.fcmToken = fcmToken
        self.photoURL = photoURL
    }
    
    enum CodingKeys: String, CodingKey  {
        case id
        case email
        case fcmToken = "fcm_token"
        case photoURL = "photo_url"
    }
}
