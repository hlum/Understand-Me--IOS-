//
//  HomeworkRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

protocol HomeworkRepository {
    func fetchHomework(id: String, studentID: String) async throws -> HomeworkWithStatus
    func fetchHomeworks(studentID: String) async throws -> [HomeworkWithStatus]
    func fetchHomeworksFromClass(classID: String, studentID: String) async throws -> [HomeworkWithStatus]
    func retryQuestionGeneration(homeworkID: String, studentID: String) async throws
}
