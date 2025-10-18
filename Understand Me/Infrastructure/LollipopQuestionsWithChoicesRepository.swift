//
//  LollipopQuestionsWithChoicesRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import Foundation

class LollipopQuestionsWithChoicesRepository: QuestionsWithChoicesRepository {
    private let lollipopAPIUtility = LollipopAPIUtility()

    
    
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
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            return []
        }
        
        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw URLError(.badServerResponse)
        }

        do {
            
            let decoder = JSONDecoder()
            let questionsWithChoices = try decoder.decode([QuestionWithChoices].self, from: jsonData)
            
            return questionsWithChoices
            
            
        }catch let DecodingError.keyNotFound(key, context) {
            print("❌ Missing key: '\(key.stringValue)' in \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            print("   Debug Description: \(context.debugDescription)")
            print("   Coding Path: \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Type mismatch for type '\(type)' at \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            print("   Debug Description: \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(value, context) {
            print("❌ Value not found for type '\(value)' at \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            print("   Debug Description: \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Data corrupted: \(context.debugDescription)")
        } catch {
            print("⚠️ Unknown decoding error: \(error)")
        }
        return []
    }
    

}
