//
//  TestHomeworkRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/20.
//

import Foundation

class TestHomeworkRepository: HomeworkRepository {
    func retryQuestionGeneration(homeworkID: String, studentID: String) async throws {
        return
    }
    
    func fetchHomework(id: String, studentID: String) async throws -> HomeworkWithStatus {
        return .getDummy(submissionState: .failed)
    }
    
    func fetchHomeworks(studentID: String) async throws -> [HomeworkWithStatus] {
        [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
    }
    
    func fetchHomeworksFromClass(classID: String, studentID: String) async throws -> [HomeworkWithStatus] {
        [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
    }
    
    
}
