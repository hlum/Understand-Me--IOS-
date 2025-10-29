//
//  AppRouter.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/29.
//

import SwiftUI
import Combine

// selectedHomeworkID に通知の内容からのHomeworkIDを設定すれば、HomeworkDetailViewに遷移する
// 遷移の実装はMainTabViewの中
class AppRouter: ObservableObject {
    @Published var selectedHomeworkID: String? = nil
}
