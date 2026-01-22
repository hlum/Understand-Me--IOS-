//
//  TestQuestionsWithChoicesRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/27.
//

import Foundation

class TestQuestionsWithChoicesRepository: QuestionsWithChoicesRepository {
    func fetchCorrectChoice(homeworkID: String, questionID: String) async throws -> Choice {
        return Choice.getDummy()
    }
    
    func fetchQuestionsChoices(homeworkID: String, userID: String) async throws -> [QuestionWithChoices] {
        return [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
    }
}
