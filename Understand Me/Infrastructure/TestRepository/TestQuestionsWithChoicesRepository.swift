//
//  TestQuestionsWithChoicesRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/27.
//

import Foundation

class TestQuestionsWithChoicesRepository: QuestionsWithChoicesRepository {
    func fetchAll(homeworkID: String, userID: String) async throws -> [QuestionWithChoices] {
        return [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
    }
}
