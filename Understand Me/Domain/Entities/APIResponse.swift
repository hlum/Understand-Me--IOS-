//
//  LollipopResponse.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

struct APIResponse: Codable {
    let status: String
    let error_type: String?
    let message: String
    let dataString: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case error_type
        case message
        case dataString = "data"
    }
}
