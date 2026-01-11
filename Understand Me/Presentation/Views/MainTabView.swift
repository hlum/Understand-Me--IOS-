//
//  MainTabView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedTab: Int = 0
    @State private var authDataResult: AuthDataResultModel? = nil
    @State private var isHomeworkDetailViewPresentated = false
    
    @StateObject private var viewModel = MainTabViewModel(
        userDataUseCase: UserDataUseCase(
            userDataRepository: LollipopUserDataRepository(), fcmTokenRepository: LollipopFCMTokenRepository()
        )
    )
    
    var body: some View {
        Group {
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
        .onChange(of: router.selectedHomeworkID) { oldValue, newValue in
            if newValue != nil {
                isHomeworkDetailViewPresentated = true
            }
        }
    }
    
    private var tabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack{
                HomeView(selectedTab: $selectedTab)
                    .navigationDestination(isPresented: $isHomeworkDetailViewPresentated) {
                        if let id = router.selectedHomeworkID {
                            HomeworkDetailView(id: id)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "house")
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
            .tag(1)
            
            NavigationStack{
                HomeworkListView()
                
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("課題")
            }
            .tag(2)
            
            
            
            NavigationStack{
                ProfileView {
                    authDataResult = nil
                }
            }
            .tabItem {
                Image(systemName: "person")
                Text("プロフィール")
            }
            .tag(3)
        }
        .navigationBarBackButtonHidden(true)

    }
}

#Preview {
    MainTabView()
}
