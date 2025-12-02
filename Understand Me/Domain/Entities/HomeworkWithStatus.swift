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
    let description: String?
    let dueDateString: String?
    let classID: String
    let githubURL: String?
    let submissionState: HomeworkState
    let createdAtString: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case classID = "class_id"
        case dueDateString = "due_date"
        case githubURL = "github_file_link"
        case submissionState = "submission_state"
        case createdAtString = "created_at"
    }
    
    var dueDate: Date? {
        guard let dueDateString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dueDateString)
    }
    
    var createdAt: Date {
        HomeworkWithStatus.dateFormatter.date(from: createdAtString) ?? .distantPast
    }
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    
    static func getDummy(submissionState: HomeworkState = HomeworkState.allCases.randomElement() ?? .completed) -> HomeworkWithStatus {
        return HomeworkWithStatus(
            id: UUID().uuidString,
            title: "Test Dummy",
            description: "tasfjaosifjapiwnvjasvdsvasvlkma;slvmoas a",
            dueDateString: "10-1-2",
            classID: UUID().uuidString,
            githubURL: "https:safasfdajsv;nmaskdvn",
            submissionState: submissionState,
            createdAtString: "2025-12-01"
        )
    }
}
