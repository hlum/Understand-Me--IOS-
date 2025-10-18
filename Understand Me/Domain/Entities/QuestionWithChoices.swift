//
//  QuestionWithChoices.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//


import Foundation

struct QuestionWithChoices: Codable, Identifiable {
    let id: String
    let jobID: String
    let projectID: String
    let homeworkID: String
    let userID: String
    let questionText: String
    let createdAt: String
    let choices: [Choice]

    enum CodingKeys: String, CodingKey {
        case id = "question_id"
        case jobID = "job_id"
        case projectID = "project_id"
        case homeworkID = "homework_id"
        case userID = "user_id"
        case questionText = "question_text"
        case createdAt = "created_at"
        case choices
    }
    
    
    static func getDummy() -> Self {
        return QuestionWithChoices(
            id: UUID().uuidString,
            jobID: UUID().uuidString,
            projectID: UUID().uuidString,
            homeworkID: UUID().uuidString,
            userID: UUID().uuidString,
            questionText: "TESTの質問文です。",
            createdAt: Date().description,
            choices: [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
        )
    }
}

struct Choice: Codable, Identifiable {
    let id: String
    let choiceText: String
    let isCorrect: Bool

    enum CodingKeys: String, CodingKey {
        case id = "choice_id"
        case choiceText = "choice_text"
        case isCorrect = "is_correct"
    }
    
    static func getDummy() -> Self {
        return Choice(
            id: UUID().uuidString,
            choiceText: "選択肢のテキストです。",
            isCorrect: Bool.random()
        )
    }
}
