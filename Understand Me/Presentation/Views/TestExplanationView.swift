//
//  TestExplanationView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/01/17.
//

import SwiftUI

struct TestExplanationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showQuestions: Bool
    @State private var currentStep = 0
    @State private var dontShowAgain = false
    @State private var arcProgress: Double = 0.0
    @State private var animatedTimerValue = 60

    private let totalSteps = 5

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Text("テストの説明")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)

                        Text("始める前に重要な情報を確認してください")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)

                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<totalSteps, id: \.self) { step in
                            Capsule()
                                .fill(step <= currentStep ? Color.accent : Color.gray.opacity(0.3))
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)

                    // Interactive content area
                    TabView(selection: $currentStep) {
                        // Step 0: メインタイマーの説明
                        stepMainTimer()
                            .tag(0)

                        // Step 1: アークタイマーの説明
                        stepArcTimer()
                            .tag(1)

                        // Step 2: アークタイマーの押し方
                        stepArcTimerAction()
                            .tag(2)

                        // Step 3: 戻れない警告
                        stepNoReturn()
                            .tag(3)

                        // Step 4: 最終確認
                        stepFinalConfirmation()
                            .tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)

                    Spacer()

                    // Navigation buttons
                    VStack(spacing: 16) {
                        // Don't show again toggle
                        if currentStep == totalSteps - 1 {
                            Toggle(isOn: $dontShowAgain) {
                                Text("次回から表示しない")
                                    .font(.subheadline)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .accent))
                            .padding(.horizontal, 30)
                            .padding(.bottom, 8)
                        }

                        HStack(spacing: 16) {
                            // Back button
                            if currentStep > 0 {
                                Button(action: {
                                    withAnimation {
                                        currentStep -= 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("戻る")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.accent)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.accent, lineWidth: 2)
                                    )
                                }
                            }

                            // Next/Start button
                            Button(action: {
                                if currentStep < totalSteps - 1 {
                                    withAnimation {
                                        currentStep += 1
                                    }
                                } else {
                                    // Save preference and start test
                                    if dontShowAgain {
                                        TestExplanationPreference.shared.setDontShowAgain(true)
                                    }
                                    showQuestions = true
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    Text(currentStep < totalSteps - 1 ? "次へ" : "テストを開始")
                                    if currentStep < totalSteps - 1 {
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(currentStep == totalSteps - 1 ? Color.green : Color.accent)
                                )
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("キャンセル")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }

    // MARK: - Step Views

    @ViewBuilder
    private func stepMainTimer() -> some View {
        VStack(spacing: 24) {
            // Illustration
            VStack(alignment: .leading) {
                HStack {
                    // Simulated main timer
                    Text("残り時間: \(animatedTimerValue)秒")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        )
                        .onAppear {
                            startMainTimerAnimation()
                        }

                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10)
            )

            // Explanation
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "1.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accent)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("メインタイマー")
                            .font(.title3.bold())

                        Text("左上の赤いタイマーは質問ごとの制限時間です。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("時間切れになると自動的に次の質問に進みます。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.05))
            )

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }

    @ViewBuilder
    private func stepArcTimer() -> some View {
        VStack(spacing: 24) {
            // Illustration
            VStack(spacing: 16) {
                Text("画面下部")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom,30)

                ArcTimerButton(
                    progress: $arcProgress, isRunning: .constant(true),
                    duration: 10,
                    lineWidth: 10,
                    size: 80,
                    label: "PUSH",
                    accentColor: .blue,
                    warningColor: .red
                )
                .disabled(true) // Make it non-interactive in explanation
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10)
            )

            // Explanation
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "2.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("アークタイマー")
                            .font(.title3.bold())

                        Text("画面下部の円形タイマーは10秒ごとにリセットされます。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("このタイマーは常に動いています。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.orange.opacity(0.05))
            )

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }

    @ViewBuilder
    private func stepArcTimerAction() -> some View {
        VStack(spacing: 24) {
            // Interactive illustration
            VStack(spacing: 16) {
                Text("タップしてリセット!")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)

                ArcTimerButton(
                    progress: $arcProgress, isRunning: .constant(true),
                    duration: 10,
                    lineWidth: 10,
                    size: 80,
                    label: "PUSH",
                    accentColor: .blue,
                    warningColor: .red,
                    onComplete: {}
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10)
            )

            // Explanation
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "3.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("重要: 10秒ごとにタップ!")
                            .font(.title3.bold())
                            .foregroundColor(.red)

                        Text("アークタイマーが一周する前(10秒以内)に必ずタップしてください。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("タップし忘れると、自動的に次の質問に進んでしまいます。")
                            .font(.body)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.05))
            )

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }

    @ViewBuilder
    private func stepNoReturn() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Warning illustration
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)

                    Text("注意!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                )

                // Warnings
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "4.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("戻ることができません")
                                .font(.title3.bold())

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text("テストを開始すると、途中で戻ることはできません。")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text("アプリを閉じたり、戻るボタンを押すと、再受験できなくなります。")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("集中できる環境で、最後まで完了する準備をしてから始めてください。")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.05))
                )

                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
        }
    }

    @ViewBuilder
    private func stepFinalConfirmation() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary icon
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)

                    Text("準備完了!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                )

                // Summary
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "5.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("テスト概要")
                                .font(.title3.bold())

                            VStack(alignment: .leading, spacing: 10) {
                                SummaryRow(
                                    icon: "timer",
                                    color: .red,
                                    text: "メインタイマー(左上)で各質問の時間管理"
                                )

                                SummaryRow(
                                    icon: "arrow.clockwise",
                                    color: .orange,
                                    text: "アークタイマー(下部)を10秒ごとにタップ"
                                )

                                SummaryRow(
                                    icon: "hand.raised.fill",
                                    color: .purple,
                                    text: "タイマーを忘れると次の質問へ自動移動"
                                )

                                SummaryRow(
                                    icon: "lock.fill",
                                    color: .blue,
                                    text: "開始後は戻れません・再受験不可"
                                )
                            }
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.05))
                )

                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
        }
    }

    // MARK: - Helper Functions

    private func startMainTimerAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation {
                if animatedTimerValue > 0 {
                    animatedTimerValue -= 1
                } else {
                    animatedTimerValue = 60
                }
            }
        }
    }
}

// MARK: - Summary Row Component
struct SummaryRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - UserDefaults Preference Manager
class TestExplanationPreference {
    static let shared = TestExplanationPreference()

    private let key = "dontShowTestExplanation"

    func shouldShowExplanation() -> Bool {
        return !UserDefaults.standard.bool(forKey: key)
    }

    func setDontShowAgain(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showQuestions = false

    TestExplanationView(showQuestions: $showQuestions)
}
