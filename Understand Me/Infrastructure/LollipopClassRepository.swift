//
//  LollipopClassRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation


enum ClassRepositoryError: LocalizedError {
    case InvalidURL
    case NoDataFoundInResponse
    
    var errorDescription: String? {
        switch self {
        case .InvalidURL:
            return "URL が無効です。"
        case .NoDataFoundInResponse:
            return "データが返っていません。"
        }
    }
}

class LollipopClassRepository: ClassRepository {
    
    private let lollipopAPIUtility: LollipopAPIUtility = LollipopAPIUtility()

    func fetchAll(studentID: String) async throws -> [Class] {
        let url = try lollipopAPIUtility.makeURL("class/get_class.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "student_id", value: studentID)
        ]
        
        guard let finalURL = components?.url else {
            throw ClassRepositoryError.InvalidURL
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
            throw ClassRepositoryError.NoDataFoundInResponse
        }

        do {
            let classes = try JSONDecoder().decode([Class].self, from: jsonData)
            return classes
        } catch {
            print("ClassのDecodeに失敗。失敗: \(error.localizedDescription)")
            throw error
        }
    }
}
