//
//  AnswerRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/19.
//

import Foundation

protocol AnswerRepository {
    func postAnswer(answer: Answer, homeworkID: String, totalQuestions: Int) async throws
    func fetchAnswers(homeworkID: String, userID: String) async throws -> [Answer]
}
