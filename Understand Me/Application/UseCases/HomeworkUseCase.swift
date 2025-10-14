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
    
    
    
    func fetchHomeworks(studentID: String) async throws -> [HomeworkWithStatus] {
        try await homeworkRepository.fetchHomeworks(studentID: studentID)
    }
    
    
    
    func fetchHomeworks(studentID: String, classID: String) async throws -> [HomeworkWithStatus] {
        try await homeworkRepository.fetchHomeworksFromClass(classID: classID, studentID: studentID)
    }
}
