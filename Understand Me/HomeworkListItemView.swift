//
//  HomeworkListCellView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI

struct HomeworkListItemView: View {
    var title: String
    var dueDate: Date
    var state: HomeworkState
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text("提出期限：\(formattedDate(dueDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if state != .generatingQuestions && state != .completed {
                Text(state.stateDescription)
                    .font(.caption.bold())
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(state.color.opacity(0.15))
                    .foregroundColor(state.color)
                    .cornerRadius(12)
            } else if state == .completed {
                Image(systemName: "checkmark.circle")
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.green)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: .primary.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}
