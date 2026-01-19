//
//  LollipopResultRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/21.
//

import Foundation
import OSLog

class LollipopResultRepository: ResultRepository {
    let lollipopUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")
    
    
    func fetchResults(userID: String) async throws -> [ResultData] {
        let url = try lollipopUtility.makeURL("result/get_result.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "user_id", value: userID),
        ]
        
        guard let finalURL = components?.url else {
            throw LollipopError.InvalidURL
        }
        
        let request = try await lollipopUtility.makeRequest(url: finalURL, method: "GET")

        let (data, _) = try await URLSession.shared.data(for: request)

        let response: APIResponse<ResultData> = try lollipopUtility.decodeAPIResponse(from: data)

        guard let result = response.dataString else {
            throw URLError(.badServerResponse)
        }

       return result
    }



    func fetchResult(userID: String, homeworkID: String) async throws -> ResultData {
        let url = try lollipopUtility.makeURL("result/get_result_userID_homeworkID.php")

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "homework_id", value: homeworkID)
        ]

        guard let finalURL = components?.url else {
            throw LollipopError.InvalidURL
        }

        let request = try await lollipopUtility.makeRequest(url: finalURL, method: "GET")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<ResultData> = try lollipopUtility.decodeAPIResponse(from: data)
        
        guard let results = response.dataString,
              let result = results.first else {
            throw URLError(.badServerResponse)
        }

       return result
    }
}
