//
//  MainTabView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab: Int = 0
    @State private var authDataResult: AuthDataResultModel? = nil
    
    
    @StateObject private var viewModel = MainTabViewModel(
        userDataUseCase: UserDataUseCase(
            userDataRepository: LollipopUserDataRepository()
        )
    )
    
    var body: some View {
        if authDataResult == nil {
            LoginInView { authDataResult in
                Task {
                    await viewModel.saveUserDataIfNotExist(authDataResult: authDataResult)
                    withAnimation(.spring) {
                        self.authDataResult = authDataResult
                    }
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))

        } else {
            tabView
                .task {
                    if let authDataResult = self.authDataResult {
                        await viewModel.loadUserData(userID: authDataResult.id)
                    }
                }
        }
    }
    
    private var tabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack{
                HomeView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("ホーム")
            }
            .tag(0)
            
            
            NavigationStack{
                ClassListView()
                
            }
            .tabItem {
                Image(systemName: "graduationcap")
                Text("クラス")
            }
            
            NavigationStack{
                HomeworkListView()
                
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle.portrait")
                Text("課題")
            }
            
            
            
            NavigationStack{
                ProfileView {
                    authDataResult = nil
                }
            }
            .tabItem {
                Image(systemName: "person")
                Text("プロフィール")
            }
        }
        .navigationBarBackButtonHidden(true)

    }
}

#Preview {
    MainTabView()
}
