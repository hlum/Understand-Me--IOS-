//
//  LollipopAPIUtilityClass.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation

class LollipopAPIUtility {
    private let secretLoader = SecretLoader.shared

    func makeURL(_ path: String) throws -> URL {
        let base = secretLoader.fetchSecret(from: "Secrets", forKey: "endpoint")
        guard let baseURL = URL(string: base)?.appendingPathComponent(path) else {
            throw LollipopError.InvalidURL
        }
        return baseURL
    }
    
    
    
    func makeRequest(url: URL, method: String, body: Data? = nil) throws -> URLRequest {
        let apiKey = secretLoader.fetchSecret(from: "Secrets", forKey: "APIKEY")
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.httpBody = body
        return request
    }
    
    
    
    func decodeAPIResponse(from data: Data) throws -> APIResponse {
        try JSONDecoder().decode(APIResponse.self, from: data)
    }
    
}
