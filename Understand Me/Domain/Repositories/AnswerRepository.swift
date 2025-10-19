//
//  AnswerRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/19.
//

import Foundation

protocol AnswerRepository {
    func postAnswer(answer: Answer, totalQuestions: Int) async throws
}
