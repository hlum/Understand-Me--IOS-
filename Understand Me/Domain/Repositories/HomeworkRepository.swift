//
//  HomeworkRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

protocol HomeworkRepository {
    func fetchHomeworks(studentID: String) async throws -> [Homework]
    func fetchHomeworksFromClass(classID: String, studentID: String) async throws -> [Homework]
}
