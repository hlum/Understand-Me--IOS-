//
//  MainTabView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct MainTabView: View {
    @State private var selection: Int = 0
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                HomeView()
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
        }
    }
}

#Preview {
    MainTabView()
}
