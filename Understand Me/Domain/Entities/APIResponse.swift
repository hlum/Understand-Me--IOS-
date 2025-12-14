//
//  LollipopResponse.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let status: String
    let error_type: ErrorType?
    let message: String
    let dataString: [T]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case error_type
        case message
        case dataString = "data"
    }
}

enum ErrorType: String, Codable {
    case validation_error
    case auth_error
    case forbidden_error
    case not_found_error
    case server_error
    case unsupported_file_type
    case unsupported_repo_url
    
}


struct EmptyResponse: Codable {}
