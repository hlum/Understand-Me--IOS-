//
//  ResultUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/21.
//

import Foundation

class ResultUseCase {
    private let resultRepo: ResultRepository
    
    init(resultRepo: ResultRepository) {
        self.resultRepo = resultRepo
    }
    
    
    func fetchResults(userID: String, year: Int) async throws -> [Result] {
        try await resultRepo.fetchResults(userID: userID, year: year)
    }
}
