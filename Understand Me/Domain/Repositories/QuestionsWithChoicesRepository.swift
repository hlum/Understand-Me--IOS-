//
//  QuestionsWithChoicesRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import Foundation

protocol QuestionsWithChoicesRepository {
    func fetchQuestionsChoices(homeworkID: String, userID: String) async throws -> [QuestionWithChoices]
    func fetchCorrectChoice(homeworkID: String, questionID: String) async throws -> Choice
}
