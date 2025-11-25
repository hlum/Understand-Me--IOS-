//
//  AverageScoreRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/25.
//

import Foundation

protocol AverageScoreRepository {
    func fetch(userID: String) async throws -> [AverageScorePerClass]
}
