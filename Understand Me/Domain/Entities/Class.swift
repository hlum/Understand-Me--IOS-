//
//  Class.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation

// 授業のエンティティー
struct Class: Codable {
    let id: String
    let teacherId: String // 担当先生名
    let name: String // 授業名
    let admissionYear: Int // 入学年 2024->24, 2023->23
    let majorCode: String // 専攻コード 例： cm, ac..
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case teacherId = "teacher_id"
        case admissionYear = "admission_year"
        case majorCode = "major_code"
    }
    
    static func getDummy() -> Self {
        return Class(
            id: UUID().uuidString,
            teacherId: UUID().uuidString,
            name: "IOSプログラミング 1",
            admissionYear: 24,
            majorCode: "cm"
        )
    }
}
