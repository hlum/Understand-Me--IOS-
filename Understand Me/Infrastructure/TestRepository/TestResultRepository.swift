//
//  TestResultRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/22.
//

import Foundation


class TestResultRepository: ResultRepository {
    func fetchResults(userID: String, year: Int) async throws -> [Result] {
        return [.getDummy(), .getDummy(), .getDummy()]
    }
}
