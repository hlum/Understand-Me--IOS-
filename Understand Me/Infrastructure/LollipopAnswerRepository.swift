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

    
}
