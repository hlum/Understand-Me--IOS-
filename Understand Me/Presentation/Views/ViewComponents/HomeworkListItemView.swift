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
    var dueDate: Date?
    var state: HomeworkState
    var onTestCompleted: (() -> Void)? = nil
    
    var body: some View {
        NavigationLink {
            HomeworkDetailView(id: id)
        } label: {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(title)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "calendar")
                    
                    if let dueDate {
                        Text(formattedDate(dueDate) + "まで")
                            .font(.caption)
                    } else {
                        Text("締切未設定")
                            .font(.caption)
                    }
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
            if state == .questionGenerated {
                AnswerButton(homeworkID: id, onTestCompleted: onTestCompleted)
            } else if state == .generatingQuestions {
                NavigationLink {
                  HomeworkDetailView(id: id)
                }label: {
                    LottieView(filename: "AI")
                }
                    .frame(width: 80, height: 80)
            } else if state == .completed {
                NavigationLink {
                    HomeworkDetailView(id: id)
                } label: {
                    Image(systemName: "checkmark.circle")
                        .bold()
                        .font(.title)
                        .foregroundStyle(.green)
                        .frame(width: 60, height: 60)
                }
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

// MARK: - Answer Button Component with Explanation Flow
struct AnswerButton: View {
    let homeworkID: String
    var onTestCompleted: (() -> Void)? = nil

    @State private var showExplanation = false
    @State private var showQuestions = false

    var body: some View {
        Button {
            // Check if we should show the explanation
            if TestExplanationPreference.shared.shouldShowExplanation() {
                showExplanation = true
            } else {
                showQuestions = true
            }
        } label: {
            Text("回答")
                .font(.headline)
                .frame(width: 70, height: 45)
                .background(.accent.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(70)
        }
        .fullScreenCover(isPresented: $showExplanation, onDismiss: {
            // Don't refresh here, only when test is actually completed
        }) {
            TestExplanationView(showQuestions: $showQuestions)
        }
        .fullScreenCover(isPresented: $showQuestions, onDismiss: {
            // Refresh the list after test completion
            onTestCompleted?()
        }) {
            QuestionsView(homeworkID: homeworkID)
        }
    }
}

#Preview {
    NavigationStack {
        HomeworkListItemView(id: "", title: "Test", dueDate: Date(), state: .completed)
    }
}
