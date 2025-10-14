//
//  Project.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

struct Project: Codable {
    let id: String
    let userID: String
    let homeworkID: String
    let githubURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case homeworkID = "homework_id"
        case githubURL = "github_file_link"
    }
}
