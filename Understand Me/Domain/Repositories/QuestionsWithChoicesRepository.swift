//
//  QuestionsWithChoicesRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import Foundation

protocol QuestionsWithChoicesRepository {
    func fetchAll(homeworkID: String, userID: String) async throws -> [QuestionWithChoices]
}
