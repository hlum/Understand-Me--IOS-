//
//  AnswerUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/19.
//

import Foundation


class AnswerUseCase {
    private let answerRepository: AnswerRepository
    
    init(answerRepository: AnswerRepository) {
        self.answerRepository = answerRepository
    }
    
    
    
    func addAnswer(answer: Answer, homeworkID: String, totalQuestions: Int) async throws {
        try await answerRepository.postAnswer(answer: answer, homeworkID: homeworkID, totalQuestions: totalQuestions)
    }
    
    
    func fetchAnswers(homeworkID: String, userID: String) async throws -> [Answer] {
        return try await answerRepository.fetchAnswers(homeworkID: homeworkID, userID: userID)
    }
    
}
