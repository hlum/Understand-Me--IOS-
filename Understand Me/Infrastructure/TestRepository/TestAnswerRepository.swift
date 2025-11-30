//
//  TestAnswerReposiotry.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/27.
//

import Foundation

class TestAnswerRepository: AnswerRepository {
    func postAnswer(answer: Answer, homeworkID: String, totalQuestions: Int) async throws {
        return
    }
    
    func fetchAnswers(homeworkID: String, userID: String) async throws -> [Answer] {
        return [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
    }
    
    
}
