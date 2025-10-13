//
//  ClassRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation

protocol ClassRepository {
    func fetchAll(studentID: String) async throws -> [Class]
}
