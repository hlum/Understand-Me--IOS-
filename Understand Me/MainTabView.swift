//
//  MainTabView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("ホーム")
            }
            .tag(0)
            
            NavigationStack {
                ClassListView()
            }
            .tabItem {
                Image(systemName: "graduationcap")
                Text("クラス")
            }
            
            NavigationStack {
                HomeworkListView()
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle.portrait")
                Text("課題")
            }
        }
    }
}

#Preview {
    MainTabView()
}
