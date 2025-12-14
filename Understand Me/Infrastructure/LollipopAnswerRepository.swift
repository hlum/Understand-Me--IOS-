//
//  LollipopAnswerRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/19.
//

import Foundation
import OSLog


class LollipopAnswerRepository: AnswerRepository {
    
    private let lollipopUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")
    
    
    
    func postAnswer(answer: Answer, homeworkID: String, totalQuestions: Int) async throws {
        let endPoint = try lollipopUtility.makeURL("answer/add_answer.php")
        let body = try JSONEncoder().encode([
            "question_id": answer.questionID,
            "homework_id": homeworkID,
            "user_id": answer.userID,
            "selected_choice_id": answer.selectedChoiceID ?? nil,
            "total_questions": "\(totalQuestions)"
        ])
        
        
        let request = try lollipopUtility.makeRequest(url: endPoint, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<EmptyResponse> = try lollipopUtility.decodeAPIResponse(from: data)
        
        try lollipopUtility.checkResponseForErrors(response)
        logger.info("解答の投稿に成功: questionID=\(answer.questionID), homeworkID=\(homeworkID)")
    }
    
    
    
    func fetchAnswers(homeworkID: String, userID: String) async throws -> [Answer] {
        let url = try lollipopUtility.makeURL("answer/get_answers_with_homeworkID.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "homework_id", value: homeworkID),
            URLQueryItem(name: "user_id", value: userID)
        ]
        
        guard let finalURL = components?.url else {
            throw LollipopError.InvalidURL
        }

        let request = try lollipopUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<Answer> = try lollipopUtility.decodeAPIResponse(from: data)
        
        try lollipopUtility.checkResponseForErrors(response)
        
        guard let answers = response.dataString else {
            throw LollipopError.NoDataFoundInResponse
        }
        
        return answers
        
    }

    
}
