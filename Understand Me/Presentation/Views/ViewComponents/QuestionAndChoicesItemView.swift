//
//  QuestionAndChoicesItemView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/18.
//

import SwiftUI
import OSLog
import Combine

// MARK: - Mode Enum
enum QuestionViewMode {
    case answering
    case review
}



struct QuestionAndChoicesItemView: View {
    var questionAndChoices: QuestionWithChoices
    var mode: QuestionViewMode = .answering
    var isLastQuestion: Bool = false
    var moveToNextQuestion: (() -> Void)? = nil
    var selectedChoiceIDFromServer: String? = nil // for review mode
    var questionCount: Int
    private let mainTimerDuration: Int = RemoteConfigManager.shared.mainTimerDuration
    private let arcTimerDuration: Int = RemoteConfigManager.shared.arcTimerDuration
    
    @State private var remainingTime: Int
    @State private var selectedChoiceID: String? = nil
    @State private var timerCancellable: Cancellable? = nil
    @State private var progressFromArcTimer: Double = 0.0
    
    @StateObject var viewModel = QuestionAndChoicesItemViewModel(
        authenticationUseCase: AuthenticationUseCase(authenticationRepository: FirebaseAuthenticationRepository()),
        questionsWithChoicesUseCase: QuestionsWIthChoicesUseCase(questionsWithChoicesRepository: LollipopQuestionsWithChoicesRepository()),
        answerUseCase: AnswerUseCase(answerRepository: LollipopAnswerRepository())
    )
    
    init(
        questionAndChoices: QuestionWithChoices,
        mode: QuestionViewMode,
        isLastQuestion: Bool = false,
        questionCount: Int,
        moveToNextQuestion: (() -> Void)? = nil,
        selectedChoiceIDFromServer: String? = nil
    ) {
        self.questionAndChoices = questionAndChoices
        self.mode = mode
        self.isLastQuestion = isLastQuestion
        self.moveToNextQuestion = moveToNextQuestion
        self.selectedChoiceIDFromServer = selectedChoiceIDFromServer
        self.questionCount = questionCount
        self._remainingTime = State(initialValue: RemoteConfigManager.shared.mainTimerDuration)
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                QuestionItemSkeleton(mode: mode)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    if mode == .answering {
                        Text("残り時間: \(remainingTime)秒")
                            .foregroundStyle(.red)
                    }
                    
                    if mode == .review && selectedChoiceIDFromServer == nil {
                        Text("未回答")
                            .foregroundStyle(.red)
                    }
                    
                    // MARK: Question
                    Text(questionAndChoices.questionText)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    
                    // MARK: Choices
                    VStack(spacing: 12) {
                        ForEach(questionAndChoices.choices) { choice in
                            ChoiceButton(
                                choice: choice,
                                isSelected: isChoiceSelected(choice),
                                correctChoiceID: $viewModel.correctChoiceID
                            )
                            .onTapGesture {
                                if mode == .answering && viewModel.correctChoiceID == nil {
                                    withAnimation(.spring()) {
                                        selectedChoiceID = choice.id
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: Next Button
                    if mode == .answering {
                        Button {
                            // correctChoiceID がないのは回答を送信してないから
                            if viewModel.correctChoiceID == nil {
                                // First tap: Submit the answer
                                if selectedChoiceID != nil {
                                    Task {
                                        await viewModel.postAnswer(questionCount: questionCount, questionID: questionAndChoices.id, homeworkID: questionAndChoices.homeworkID, selectedChoiceID: selectedChoiceID)
                                    }
                                }
                            } else {
                                // Second tap: Move to next question
                                viewModel.correctChoiceID = nil // remove the correctChoiceID
                                moveToNextQuestion?()
                                restartTimer()
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
                        .disabled(selectedChoiceID == nil || viewModel.isLoading || viewModel.submittingAnswer)
                        .opacity(selectedChoiceID == nil || viewModel.isLoading || viewModel.submittingAnswer ? 0.6 : 1)
                        .animation(.easeInOut(duration: 0.2), value: buttonColor)
                        
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                )
                .padding()
                
                Spacer()
                
                if mode == .answering {
                    ArcTimerButton(
                        progress: $progressFromArcTimer,
                        duration: TimeInterval(arcTimerDuration),
                        lineWidth: 10,
                        size: 70, label: "PUSH",
                        accentColor: .accent,
                        warningColor: .red,
                        onComplete: {
                            Task {
                                await viewModel.postAnswer(
                                    questionCount: questionCount,
                                    questionID: questionAndChoices.id,
                                    homeworkID: questionAndChoices.homeworkID,
                                    selectedChoiceID: nil
                                )
                                viewModel.correctChoiceID = nil
                                selectedChoiceID = nil
                                moveToNextQuestion?()
                                restartTimer()
                            }
                        }
                    )
                    .padding(.bottom)
                    .onAppear {
                        startTimer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            guard mode == .review else { return }
            selectedChoiceID = selectedChoiceIDFromServer
            await viewModel.loadCorrectChoice(homeworkID: questionAndChoices.homeworkID, questionID: questionAndChoices.id)
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
        mode == .review || viewModel.correctChoiceID != nil
    }
    
    private var buttonLabel: String {
        if viewModel.submittingAnswer {
            return "送信中.."
        }
        
        if viewModel.correctChoiceID == nil {
            return "回答を送信"
        } else {
            return isLastQuestion ? "完了" : "次へ"
        }
    }
    
    private var buttonColor: Color {
        if viewModel.correctChoiceID == nil {
            return .blue
        } else {
            return isLastQuestion ? .green : .orange
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remainingTime == 0 {
                    Task {
                        await viewModel.postAnswer(
                            questionCount: questionCount,
                            questionID: questionAndChoices.id,
                            homeworkID: questionAndChoices.homeworkID,
                            selectedChoiceID: nil
                        )
                        viewModel.correctChoiceID = nil
                        selectedChoiceID = nil
                        moveToNextQuestion?()
                        restartTimer()
                    }
                }
                remainingTime -= 1
            }
    }
    
    
    private func restartTimer() {
        stopTimer()
        remainingTime = mainTimerDuration
        progressFromArcTimer = 0.0
        startTimer()
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}




#Preview {
    NavigationStack {
        QuestionAndChoicesItemView(questionAndChoices: .getDummy(), mode: .answering, isLastQuestion: true, questionCount: 5)
    }
}
