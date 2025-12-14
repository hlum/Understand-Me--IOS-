//
//  LollipopQuestionsWithChoicesRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import Foundation
import OSLog

class LollipopQuestionsWithChoicesRepository: QuestionsWithChoicesRepository {
    private let lollipopAPIUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")

    
    
    func fetchAll(homeworkID: String, userID: String) async throws -> [QuestionWithChoices] {
        let endpoint = try lollipopAPIUtility.makeURL("questions_choices/get_questions_choices.php")
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        
        components?.queryItems = [
            URLQueryItem(name: "homework_id", value: homeworkID),
            URLQueryItem(name: "user_id", value: userID)
        ]
        
        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<QuestionWithChoices> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard let result = response.dataString else {
            throw URLError(.badServerResponse)
        }

       return result
    }
    

}
