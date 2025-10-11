//
//  UserData.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

struct UserData {
    let id: String
    let email: String
    let fcmToken: String?
    let photoURL: URL?
    
    init(id: String, email: String, fcmToken: String?, photoURL: URL?) {
        self.id = id
        self.email = email
        self.fcmToken = fcmToken
        self.photoURL = photoURL
    }
}
