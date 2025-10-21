//
//  Result.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/21.
//

import Foundation

struct Result: Decodable {
    let id: String
    let userID: String
    let homeworkID: String
    let totalQuestions: Int
    let correctAnswers: Int
    let score: Int
    let evaluatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case homeworkID = "homework_id"
        case totalQuestions = "total_questions"
        case correctAnswers = "correct_answers"
        case score
        case evaluatedAt = "evaluated_at"
    }
    
    
    // Date形式でパースするためのカスタムイニシャライザ
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.homeworkID = try container.decode(String.self, forKey: .homeworkID)
        self.totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        self.correctAnswers = try container.decode(Int.self, forKey: .correctAnswers)
        self.score = try container.decode(Int.self, forKey: .score)
        
        // 2025-10-19 14:47:37 LollipopからのDateStringの形式
        let dateString = try container.decode(String.self, forKey: .evaluatedAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "jp_JP")
        
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .evaluatedAt,
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        
        self.evaluatedAt = date
    }
}
