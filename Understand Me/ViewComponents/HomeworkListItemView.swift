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
                
                HStack {
                    Image(systemName: "calendar")
                    
                    Text(formattedDate(dueDate))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                
                if state == .completed {
                    Image(systemName: "checkmark.circle")
                        .bold()
                        .font(.title)
                        .foregroundStyle(.green)
                        .frame(width: 60, height: 60)
                } else if state == .generatingQuestions {
                    HStack {
                        Text(state.stateDescription)
                            .font(.caption)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.3))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                            .frame(height: 60)
                        
                        LottieView(filename: "AI")
                            .frame(width: 50, height: 50)


                    }
                    .frame(height: 60)
                    .cornerRadius(40)
                } else {
                    Text(state.stateDescription)
                        .font(.caption.bold())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(state.color.opacity(0.15))
                        .foregroundColor(state.color)
                        .cornerRadius(12)
                        .frame(height: 60)
                }
            }
            
            Spacer()
            
            if state == .questionsGenerated {
                Button {
                    
                } label: {
                    Text("回答")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 100, height: 45)
                        .background(.accent.opacity(0.4))
                        .foregroundColor(.primary)
                        .cornerRadius(70)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: .primary.opacity(0.3), radius: 1)
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
    HomeworkListItemView(title: "Test", dueDate: Date(), state: .questionsGenerated)
}
