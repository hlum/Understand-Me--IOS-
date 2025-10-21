//
//  HomeworkUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

class HomeworkUseCase {
    private let homeworkRepository: HomeworkRepository
    
    init(homeworkRepository: HomeworkRepository) {
        self.homeworkRepository = homeworkRepository
    }
    
    
    
    func fetchHomework(id: String, studentID: String) async throws -> HomeworkWithStatus {
        try await homeworkRepository.fetchHomework(id: id, studentID: studentID)
    }
    
    
    func fetchHomeworks(studentID: String) async throws -> [HomeworkWithStatus] {
        try await homeworkRepository.fetchHomeworks(studentID: studentID)
    }
    
    
    
    func fetchHomeworks(studentID: String, classID: String) async throws -> [HomeworkWithStatus] {
        try await homeworkRepository.fetchHomeworksFromClass(classID: classID, studentID: studentID)
    }
    
    
    func retryQuestionGeneration(homeworkID: String, studentID: String) async throws {
        try await homeworkRepository.retryQuestionGeneration(homeworkID: homeworkID, studentID: studentID)
    }
    
    
    func cancelHomeworkSubmission(homeworkID: String, studentID: String) async throws {
        try await homeworkRepository.cancelHomeworkSubmission(homeworkID: homeworkID, studentID: studentID)
    }
}
