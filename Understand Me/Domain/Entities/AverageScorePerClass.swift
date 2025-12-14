//
//  AverageScorePerClass.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/25.
//

import Foundation

struct AverageScorePerClass: Identifiable, Codable {
    let id: String = UUID().uuidString
    let className: String
    let averageScore: Int
    let finishedHomeworkCount: Int
    let totalHomeworkCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case className = "class_name"
        case averageScore = "average_score"
        case finishedHomeworkCount = "finished_homework_count"
        case totalHomeworkCount = "total_homework_count"
    }
    
}
