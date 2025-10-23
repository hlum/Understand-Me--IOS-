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
    
    
    func calculateAverageResultsPerMonth(results: [Result], year: Int) -> [AverageResultPerMonth] {
        let calendar = Calendar.current
        var averageResultsPerMonth: [AverageResultPerMonth] = []
        
        // 指定した年の結果を先に抽出
        let yearResults = results.filter {
            calendar.component(.year, from: $0.evaluatedAt) == year
        }
        
        for month in 1...12 {
            // 指定した月の結果を抽出
            let monthResults = yearResults.filter {
                calendar.component(.month, from: $0.evaluatedAt) == month
            }
            
            // 指定した月の結果が存在する場合にのみ平均を計算
            if !monthResults.isEmpty {
                let averageResultForMonth = AverageResultPerMonth(resultsOfOneMonth: monthResults)
                averageResultsPerMonth.append(averageResultForMonth)
            } else {
                // 結果が存在しない場合は、平均スコアを0として追加(グラフ表示のため)
                let dateComponents = DateComponents(year: year, month: month, day: 1)
                if let monthDate = calendar.date(from: dateComponents) {
                    let emptyResult = AverageResultPerMonth(month: monthDate, averageScore: 0)
                    averageResultsPerMonth.append(emptyResult)
                }
            }
        }
        
        return averageResultsPerMonth
    }
    
}
