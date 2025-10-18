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
    let studentCode: String
    let majorCode: String
    let admissionYear: Int
    let photoURL: String?
    
    
    var displayName: String {
        if studentCode == "99zz"{
            return "Guest"
        }
        return studentCode
    }
    
    init(id: String, email: String, fcmToken: String?, studentCode: String, majorCode: String, admissionYear: Int, photoURL: String?) {
        self.id = id
        self.email = email
        self.fcmToken = fcmToken
        self.studentCode = studentCode
        self.majorCode = majorCode
        self.admissionYear = admissionYear
        self.photoURL = photoURL
    }
    
    enum CodingKeys: String, CodingKey  {
        case id
        case email
        case fcmToken = "fcm_token"
        case photoURL = "photo_url"
        case studentCode = "student_code"
        case majorCode = "major_code"
        case admissionYear = "admission_year"
    }
    
    
    
    static func getDummy() -> Self {
        return UserData(
            id: UUID().uuidString,
            email: "24cm0138@jec.ac.jp",
            fcmToken: nil,
            studentCode: "24cm0138",
            majorCode: "24",
            admissionYear: 24,
            photoURL: "cm"
        )
    }
}
