//
//  HomeworkListCellView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI

struct HomeworkListItemView: View {
    var id: String
    var title: String
    var dueDate: Date
    var state: HomeworkState
    
    var body: some View {
        NavigationLink {
            HomeworkDetailView(title: title, description: "description", homeworkState: state, dueDate: dueDate, className: "class name")
        } label: {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(title)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "calendar")
                    
                    Text(formattedDate(dueDate) + "まで")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
               
                if state == .generatingQuestions {
                    HStack {
                        Text(state.stateDescription)
                            .font(.caption)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.3))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        
                    }
                    .cornerRadius(40)
                } else {
                    Text(state.stateDescription)
                        .font(.caption.bold())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(state.color.opacity(0.15))
                        .foregroundColor(state.color)
                        .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.foreground)
        }
        .overlay(alignment: .trailing, content: {
            if state == .questionsGenerated {
                Button {
                    
                } label: {
                    Text("回答")
                        .font(.headline)
                        .frame(width: 70, height: 45)
                        .background(.accent.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(70)
                }
            } else if state == .generatingQuestions {
                LottieView(filename: "AI")
                    .frame(width: 80, height: 80)
            } else if state == .completed {
                Image(systemName: "checkmark.circle")
                    .bold()
                    .font(.title)
                    .foregroundStyle(.green)
                    .frame(width: 60, height: 60)
            }
        })
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: .primary.opacity(0.7), radius: 1)
        )
        .padding(.horizontal)
    }

    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        HomeworkListItemView(id: "", title: "Test", dueDate: Date(), state: .questionsGenerated)
    }
}
