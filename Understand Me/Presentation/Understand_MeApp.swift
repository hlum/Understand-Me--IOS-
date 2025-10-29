//
//  Understand_MeApp.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI

@main
struct Understand_MeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var router = AppRouter()
    
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(router)
                .onAppear {
                    delegate.router = router
                }
        }
    }
}
