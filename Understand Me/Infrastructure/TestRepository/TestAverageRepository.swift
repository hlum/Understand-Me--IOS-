//
//  TestAverageRepository.swift
//  Understand Me
//
//  Created by アウン on 2026/01/08.
//

import Foundation

class TestAverageRepository: AverageScoreRepository {
    func fetch(userID: String) async throws -> [AverageScorePerClass] {
        return [AverageScorePerClass.getDummy(), AverageScorePerClass.getDummy(), AverageScorePerClass.getDummy()]
    }
    
}
