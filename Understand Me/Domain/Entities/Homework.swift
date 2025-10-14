//
//  Homework.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

struct HomeworkWithStatus: Identifiable, Decodable {
    var id: String
    let title: String
    let dueDateString: String
    let githubURL: String?
    let submissionState: HomeworkState
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case dueDateString = "due_date"
        case githubURL = "github_file_link"
        case submissionState = "submission_state"
    }
    
    var dueDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dueDateString)
    }
}
