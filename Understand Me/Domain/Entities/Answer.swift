//
//  Answer.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/19.
//

import Foundation

struct Answer: Identifiable, Codable {
    let id: String
    let questionID: String
    let userID: String
    let selectedChoiceID: String
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionID = "question_id"
        case userID = "user_id"
        case selectedChoiceID = "selected_choice_id"
    }
}
