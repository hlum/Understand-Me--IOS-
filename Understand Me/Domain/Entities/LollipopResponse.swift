//
//  LollipopResponse.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

struct LollipopResponse: Codable {
    let status: String
    let message: String
    let dataString: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case dataString = "data"
    }
}
