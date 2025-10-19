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
    
    func fetchAll(homeworkID: String, userID: String) async throws -> [QuestionWithChoices] {
        try await questionsWithChoicesRepository.fetchAll(homeworkID: homeworkID, userID: userID)
    }
    
}
