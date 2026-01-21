//
//  ChoiceButton.swift
//  Understand Me
//
//  Created by アウン on 2026/01/20.
//

import SwiftUI

// MARK: - Choice Button
struct ChoiceButton: View {
    let choice: Choice
    let isSelected: Bool
    @Binding var correctChoiceID: String?

    var body: some View {
        HStack {
            Text(choice.choiceText)
                .font(.body)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.primary)
                .lineLimit(nil)
                .layoutPriority(1)

            Spacer(minLength: 8)
            
            ZStack {
                if let correctChoiceID {
                    // Submitted
                    if correctChoiceID == choice.id {
                        // Submitted and is correct
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                    }  else if isSelected {
                        // Submitted but the answer is wrong
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .transition(.scale.combined(with: .opacity))
                    }
                } else if isSelected {
                    // Not Submitted, but selected
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.blue)
                } else {
                    // Invisible circle for padding
                    Image(systemName: "circle.fill")
                        .opacity(0.0001)
                }
            }
            .frame(width: 24, height: 24)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: correctChoiceID)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : .clear, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
    }
}
