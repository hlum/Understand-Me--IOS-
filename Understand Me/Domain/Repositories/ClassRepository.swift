//
//  ClassRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation

protocol ClassRepository {
    func fetch(id: String) async throws -> Class
    func fetch(classCode: String) async throws -> Class?
    func fetchAll(studentID: String) async throws -> [Class]
    func addOptionalClass(classCode: String, userID: String) async throws
}
