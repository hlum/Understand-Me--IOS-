//
//  LollipopResultRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/21.
//

import Foundation

class LollipopResultRepository: ResultRepository {
    let lollipopUtility = LollipopAPIUtility()
    
    
    func fetchResults(userID: String, year: Int) async throws -> [Result] {
        let url = try lollipopUtility.makeURL("result/get_result.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "year", value: String(year))
        ]
        
        guard let finalURL = components?.url else {
            throw LollipopError.InvalidURL
        }
        
        let request = try lollipopUtility.makeRequest(url: finalURL, method: "GET")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopUtility.decodeAPIResponse(from: data)
        
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
            let results = try decoder.decode([Result].self, from: jsonData)
            
            return results
            
        }catch {
            let rawString = String(data: jsonData, encoding: .utf8) ?? "nil"
            print("Decodeに失敗したDataの中身：　\(rawString)")
            print("Result のDecodeに失敗しました：　\(error.localizedDescription)")
            throw error
        }
    }
}
