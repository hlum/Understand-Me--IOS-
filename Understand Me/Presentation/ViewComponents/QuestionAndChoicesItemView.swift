//
//  QuestionAndChoicesItemView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import SwiftUI

import SwiftUI

// MARK: - Mode Enum
enum QuestionViewMode {
    case answering
    case review
}

struct QuestionAndChoicesItemView: View {
    var questionAndChoices: QuestionWithChoices
    var mode: QuestionViewMode = .answering
    var isLastQuestion: Bool = false
    var onClickNext: ((_ selectedChoiceID: String) -> Void)? = nil
    var selectedChoiceIDFromServer: String? = nil // for review mode
    
    @State private var selectedChoiceID: String? = nil
    @State private var submitted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: Question
            Text(questionAndChoices.questionText)
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            
            // MARK: Choices
            VStack(spacing: 12) {
                ForEach(questionAndChoices.choices) { choice in
                    ChoiceButton(
                        choice: choice,
                        isSelected: isChoiceSelected(choice),
                        submitted: isSubmitted
                    )
                    .onTapGesture {
                        if mode == .answering && !submitted {
                            withAnimation(.spring()) {
                                selectedChoiceID = choice.id
                            }
                        }
                    }
                }
            }
            
            // MARK: Button (only for answering mode)
            if mode == .answering {
                Button {
                    withAnimation(.easeInOut) {
                        if !submitted {
                            submitted = true
                        } else {
                            submitted = false
                            if let id = selectedChoiceID {
                                onClickNext?(id)
                            }
                        }
                    }
                } label: {
                    Text(buttonLabel)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(buttonColor)
                        .cornerRadius(14)
                }
                .disabled(selectedChoiceID == nil && !submitted)
                .opacity(selectedChoiceID == nil && !submitted ? 0.6 : 1)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .padding()
        .onAppear {
            if mode == .review {
                submitted = true
                selectedChoiceID = selectedChoiceIDFromServer
            }
        }
    }
    
    // MARK: Helpers
    private func isChoiceSelected(_ choice: Choice) -> Bool {
        if mode == .answering {
            return selectedChoiceID == choice.id
        } else {
            return selectedChoiceIDFromServer == choice.id
        }
    }
    
    private var isSubmitted: Bool {
        mode == .review || submitted
    }
    
    private var buttonLabel: String {
        if !submitted {
            return "回答を送信"
        } else {
            return isLastQuestion ? "完了" : "次へ"
        }
    }
    
    private var buttonColor: Color {
        if !submitted {
            return .blue
        } else {
            return isLastQuestion ? .green : .orange
        }
    }
}

// MARK: - Choice Button
struct ChoiceButton: View {
    let choice: Choice
    let isSelected: Bool
    let submitted: Bool
    
    var body: some View {
        HStack {
            Text(choice.choiceText)
                .font(.body)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.primary)
                .lineLimit(nil)
            
            Spacer()
            
            if submitted {
                if choice.isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
            } else if isSelected {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.blue)
            } else {
                Image(systemName: "circle.fill")
                    .opacity(0.0001)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : .clear, lineWidth: 2)
                )
        )
    }
}



#Preview {
    NavigationStack {
        QuestionAndChoicesItemView(questionAndChoices: .getDummy(), isLastQuestion: true, onClickNext: { selectedChoiceID in })
    }
}
