//
//  LollipopAnswerRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/19.
//

import Foundation
import OSLog


struct PostAnswerResponse: Codable {
    let correctChoiceID: String
    
    enum CodingKeys: String, CodingKey {
        case correctChoiceID = "correct_choice_id"
    }
}

class LollipopAnswerRepository: AnswerRepository {
    
    private let lollipopUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")
    
    
    
    func postAnswer(answer: Answer, homeworkID: String, totalQuestions: Int) async throws -> String{
        let endPoint = try lollipopUtility.makeURL("answer/add_answer.php")
        let body = try JSONEncoder().encode([
            "question_id": answer.questionID,
            "homework_id": homeworkID,
            "user_id": answer.userID,
            "selected_choice_id": answer.selectedChoiceID ?? nil,
            "total_questions": "\(totalQuestions)"
        ])
        
        
        let request = try await lollipopUtility.makeRequest(url: endPoint, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        logger.debug("Response raw data: \(String(data: data, encoding: .utf8) ?? "Can't decode data")")
        let response: APIResponse<PostAnswerResponse> = try lollipopUtility.decodeAPIResponse(from: data)
        
        try lollipopUtility.checkResponseForErrors(response)
        
        guard let answerReponse = response.dataString,
              let postAnswerResponse = answerReponse.first
        else {
            throw LollipopError.NoDataFoundInResponse
        }
        
        logger.info("解答の投稿に成功: questionID=\(answer.questionID), homeworkID=\(homeworkID) 正解ID：\(postAnswerResponse.correctChoiceID)")
        
        return postAnswerResponse.correctChoiceID
        
        
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

        let request = try await lollipopUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<Answer> = try lollipopUtility.decodeAPIResponse(from: data)
        
        try lollipopUtility.checkResponseForErrors(response)
        
        guard let answers = response.dataString else {
            throw LollipopError.NoDataFoundInResponse
        }
        
        return answers
        
    }

    
}
