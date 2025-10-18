//
//  QuestionsView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import SwiftUI

struct QuestionsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = 0
    @State var questionsAndChoices: [QuestionWithChoices] = [.getDummy(), .getDummy(), .getDummy()]
    var body: some View {
        VStack {
            QuestionAndChoicesItemView(
                questionAndChoices: questionsAndChoices[currentIndex],
                isLastQuestion: currentIndex == questionsAndChoices.count - 1,
                onClickNext: {
                    if currentIndex < questionsAndChoices.count - 1 {
                        currentIndex += 1
                    } else {
                        // Quiz 終了、前のViewに戻る
                        dismiss()

                    }
                    
                })
            
            Spacer()
        }
        .navigationTitle("質問一覧")
    }
}

#Preview {
    NavigationStack {
        QuestionsView()
    }
}
