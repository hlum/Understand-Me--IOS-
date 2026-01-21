//
//  QuestionsWIthChoicesUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import Foundation

class QuestionsWIthChoicesUseCase {
    private let questionsWithChoicesRepository: QuestionsWithChoicesRepository
    
    init(questionsWithChoicesRepository: QuestionsWithChoicesRepository) {
        self.questionsWithChoicesRepository = questionsWithChoicesRepository
    }
    
    func fetchQuestionsChoices(homeworkID: String, userID: String) async throws -> [QuestionWithChoices] {
        try await questionsWithChoicesRepository.fetchQuestionsChoices(homeworkID: homeworkID, userID: userID)
    }
    
    
    func fetchCorrectChoice(homeworkID: String, questionID: String) async throws -> Choice  {
        try await questionsWithChoicesRepository.fetchCorrectChoice(homeworkID: homeworkID, questionID: questionID)
    }
    
}
