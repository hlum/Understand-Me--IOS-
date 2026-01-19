//
//  SiriIntents.swift
//  Understand Me
//
//  Created for Siri integration
//

import AppIntents
import Foundation

// MARK: - Get Average Score Intent
struct GetAverageScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "平均スコアを取得"
    static var description: IntentDescription = IntentDescription("あなたの平均スコアを取得します。")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        let defaultsGroup = UserDefaults(suiteName: "group.jp.ac.jec.24cm0138.understandme")
        let averageScore = defaultsGroup?.integer(forKey: "KNOW_YOUR_CODE_AVERAGE_SCORE_KEY") ?? 0

        let dialog: IntentDialog
        if averageScore == 0 {
            dialog = "まだ平均スコアのデータがありません。"
        } else {
            dialog = "あなたの平均スコアは\(averageScore)点です。"
        }

        return .result(value: averageScore, dialog: dialog)
    }
}

// MARK: - Get Homework Progress Intent
struct GetHomeworkProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "課題進捗を取得"
    static var description: IntentDescription = IntentDescription("課題の完成度を取得します。")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        let defaultsGroup = UserDefaults(suiteName: "group.jp.ac.jec.24cm0138.understandme")
        let homeworkProgress = defaultsGroup?.integer(forKey: "KNOW_YOUR_CODE_HOMEWORK_PROGRESS_KEY") ?? 0

        let dialog: IntentDialog
        if homeworkProgress == 0 {
            dialog = "まだ課題進捗のデータがありません。"
        } else {
            dialog = "あなたの課題完成度は\(homeworkProgress)パーセントです。"
        }

        return .result(value: homeworkProgress, dialog: dialog)
    }
}

// MARK: - App Shortcuts Provider
struct KnowYourCodeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetAverageScoreIntent(),
            phrases: [
                "私の\(.applicationName)の平均スコアは？",
                "\(.applicationName)で平均スコアを教えて",
                "平均スコアを\(.applicationName)で確認",
                "\(.applicationName)での私の平均スコアは？",
            ],
            shortTitle: "平均スコアを取得",
            systemImageName: "chart.bar.fill"
        )

        AppShortcut(
            intent: GetHomeworkProgressIntent(),
            phrases: [
                "私の\(.applicationName)の課題進捗は？",
                "\(.applicationName)で課題の進捗を教えて",
                "課題完成度を\(.applicationName)で確認",
                "\(.applicationName)での私の課題進捗は？",
            ],
            shortTitle: "課題進捗を取得",
            systemImageName: "list.bullet.clipboard.fill"
        )
    }
}
