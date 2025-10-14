//
//  Homework.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

struct Homework: Decodable {
    let id: String
    let teacherID: String
    let classID: String
    let title: String
    let description: String
    let dueDate: Date
    
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case teacherID = "teacher_id"
        case classID = "class_id"
        case dueDate = "due_date"
    }
    
    static func getDummy() -> Self {
        return Homework(
            id: UUID().uuidString,
            teacherID: UUID().uuidString,
            classID: UUID().uuidString,
            title: "Test Title",
            description: "Test Description",
            dueDate: Date()
        )
    }
}
