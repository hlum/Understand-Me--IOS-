//
//  ClassHomeworkView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct ClassHomeworkView: View {
    var className: String
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(0..<10) { _ in
                HomeworkListItemView(title: "Test", dueDate: Date(), state: HomeworkState.allCases.randomElement()!)
            }
        }
        .navigationTitle(className)
    }
}

#Preview {
    NavigationStack {
        ClassHomeworkView(className: "IOS プログラミング")
    }
}
