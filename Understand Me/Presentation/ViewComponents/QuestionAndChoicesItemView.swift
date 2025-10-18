//
//  QuestionAndChoicesItemView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import SwiftUI

struct QuestionAndChoicesItemView: View {
    var questionAndChoices: QuestionWithChoices
    @State private var selectedChoiceID: String? = nil
    @State private var submitted = false
    
    var isLastQuestion: Bool
    var onClickNext: () -> ()
    
    init(
        questionAndChoices: QuestionWithChoices,
        isLastQuestion: Bool,
        onClickNext: @escaping () -> Void
    ) {
        self.questionAndChoices = questionAndChoices
        self.isLastQuestion = isLastQuestion
        self.onClickNext = onClickNext
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: Question Text
            Text(questionAndChoices.questionText)
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            
            // MARK: Choices
            VStack(spacing: 12) {
                ForEach(questionAndChoices.choices) { choice in
                    ChoiceButton(
                        choice: choice,
                        isSelected: selectedChoiceID == choice.id,
                        submitted: submitted
                    )
                    .onTapGesture {
                        if !submitted {
                            withAnimation(.spring()) {
                                selectedChoiceID = choice.id
                            }
                        }
                    }
                }
            }
            
            // MARK: Submit Button
            Button {
                withAnimation(.easeInOut) {
                    if !submitted {
                        submitted = true
                    } else {
                        submitted = false
                        onClickNext()
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
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .padding()
    }
    
    // MARK: Dynamic Button Text
    private var buttonLabel: String {
        if !submitted {
            return "回答を送信"
        } else {
            return isLastQuestion ? "完了" : "次へ"
        }
    }
    
    // MARK: Dynamic Button Color
    private var buttonColor: Color {
        if !submitted {
            return .blue
        } else {
            return isLastQuestion ? .green : .orange
        }
    }
}


struct ChoiceButton: View {
    let choice: Choice
    let isSelected: Bool
    let submitted: Bool
    
    var body: some View {
        HStack {
            Text(choice.choiceText)
                .font(.body)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)
            Spacer()
            
            if submitted {
                Image(systemName: choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(choice.isCorrect ? .green : .red)
            } else if isSelected {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
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
        QuestionAndChoicesItemView(questionAndChoices: .getDummy(), isLastQuestion: true, onClickNext: {})
    }
}
