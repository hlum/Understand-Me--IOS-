//
//  LollipopAnswerRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/19.
//

import Foundation


class LollipopAnswerRepository: AnswerRepository {
    
    private let lollipopUtility = LollipopAPIUtility()
    
    
    
    func postAnswer(answer: Answer, homeworkID: String, totalQuestions: Int) async throws {
        let endPoint = try lollipopUtility.makeURL("answer/add_answer.php")
        let body = try JSONEncoder().encode([
            "question_id": answer.questionID,
            "homework_id": homeworkID,
            "user_id": answer.userID,
            "selected_choice_id": answer.selectedChoiceID,
            "total_questions": "\(totalQuestions)"
        ])
        
        
        let request = try lollipopUtility.makeRequest(url: endPoint, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw LollipopError.InvalidResponseStatus
        }
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
        
        let response = try lollipopUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw LollipopError.InvalidResponseStatus
        }
        
        
        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw LollipopError.NoDataFoundInResponse
        }
        
        do {
            let answers = try JSONDecoder().decode([Answer].self, from: jsonData)
            return answers
        } catch {
            print("AnswerのDecodeに失敗。失敗: \(error.localizedDescription)")
            throw error
        }
        
    }

    
}
