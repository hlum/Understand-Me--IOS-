//
//  TestHomeworkRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/20.
//

import Foundation

class TestHomeworkRepository: HomeworkRepository {
    func fetchHomework(id: String, studentID: String) async throws -> HomeworkWithStatus {
        return .getDummy()
    }
    
    func fetchHomeworks(studentID: String) async throws -> [HomeworkWithStatus] {
        [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
    }
    
    func fetchHomeworksFromClass(classID: String, studentID: String) async throws -> [HomeworkWithStatus] {
        [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
    }
    
    
}
