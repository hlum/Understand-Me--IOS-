//
//  TestResultRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/22.
//

import Foundation


class TestResultRepository: ResultRepository {
    func fetchResult(userID: String, homeworkID: String) async throws -> ResultData {
        return .getDummy()
    }
    
    func fetchResults(userID: String, year: Int) async throws -> [ResultData] {
        return [.getDummy(), .getDummy(), .getDummy()]
    }
}
