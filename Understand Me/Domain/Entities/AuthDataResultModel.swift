//
//  AuthDataResult.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel: Hashable {
    let id: String
    let email: String?
    let photoURL: URL?
    let name: String?
    
    init(user: User) {
        self.id = user.uid
        self.email = user.email
        self.photoURL = user.photoURL
        self.name = user.displayName
    }
    
    init (id: String, email: String?, photoURL: URL?, name: String? = nil) {
        self.id = id
        self.email = email
        self.photoURL = photoURL
        self.name = name
    }
    
    static func dummy() -> AuthDataResultModel {
        return AuthDataResultModel(
            id: "Test Id",
            email: "fadsfasdf@gmail.com",
            photoURL: nil,
            name: "Test User"
        )
    }
}
