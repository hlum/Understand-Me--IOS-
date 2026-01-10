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


    @concurrent
    func fetchHomeworksNearDeadline(studentID: String) async throws -> [HomeworkWithStatus] {
        var allHomeworks = try await homeworkRepository.fetchHomeworks(studentID: studentID)
        
        // 1. Filter (.completed じゃないものだけ)
        allHomeworks = allHomeworks.filter { $0.submissionState != .completed }
        
        
        // 2. Sort: dueDate(昇順),
        //    submissionStateの順に並び替え(.notAssigned, .failed, .questionGenerated, .generatingQuestions)
        allHomeworks.sort { lhs, rhs in
            // dueDateのUnwarp
            let lhsDate = lhs.dueDate ?? .distantFuture
            let rhsDate = rhs.dueDate ?? .distantFuture
            
            
            if lhsDate != rhsDate {
                return lhsDate < rhsDate
            } else {
                
                // submissionStateの優先順位を定義
                let submissionStatePriority: [HomeworkState: Int] = [
                    .notAssigned: 0,
                    .failed: 1,
                    .questionGenerated: 2,
                    .generatingQuestions: 3,
                ]
                
                
                return (submissionStatePriority[lhs.submissionState] ?? Int.max < submissionStatePriority[rhs.submissionState] ?? Int.max)
            }
        }
        
        // return only top ten
        return Array(allHomeworks.prefix(10))
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
