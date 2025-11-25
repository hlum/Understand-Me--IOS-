//
//  LollipopAverageScoreRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/25.
//

import Foundation
import OSLog

class LollipopAverageScoreRepository: AverageScoreRepository {
    private let lollipopUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")

    
    func fetch(userID: String) async throws -> [AverageScorePerClass] {
        let endpoint = try lollipopUtility.makeURL("average_score/get_average_score.php")
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "student_id", value: userID)
        ]
        
        
        guard let finalURL = components?.url else {
            throw LollipopError.InvalidURL
        }
        
        
        let request = try lollipopUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopUtility.decodeAPIResponse(from: data)
        
        try lollipopUtility.checkResponseForErrors(response)
        
        
        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw LollipopError.NoDataFoundInResponse
        }
        
        do {
            let averageScores = try JSONDecoder().decode([AverageScorePerClass].self, from: jsonData)
 
            logger.info("学科ごとの平均スコアカウント: \(averageScores)")
            return averageScores
        } catch {
            logger.error("Error decoding JSON: \(error)")
            throw error
        }
    }
}
