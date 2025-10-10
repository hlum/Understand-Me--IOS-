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
    
    init(user: User) {
        self.id = user.uid
        self.email = user.email
        self.photoURL = user.photoURL
    }
    
    init (id: String, email: String?, photoURL: URL?) {
        self.id = id
        self.email = email
        self.photoURL = photoURL
    }
    
    static func dummy() -> AuthDataResultModel {
        return AuthDataResultModel(
            id: "Test Id",
            email: "fadsfasdf@gmail.com",
            photoURL: nil
        )
    }
}
