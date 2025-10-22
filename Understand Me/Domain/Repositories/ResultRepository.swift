//
//  ResultRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/21.
//

import Foundation

protocol ResultRepository {
    func fetchResults(userID: String, year: Int) async throws -> [Result]
}
