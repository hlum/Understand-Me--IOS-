//
//  ProfileView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/09.
//

import SwiftUI
import Charts


struct ProfileView: View {
    @State private var data: [AverageResultPerMonth] = AverageResultPerMonth.getDummy()
    
    var onSignOut: () -> ()
    
    @StateObject private var viewModel: ProfileViewModel
    
    init(
        authenticationUseCase: AuthenticationUseCase = AuthenticationUseCase(authenticationRepository:FirebaseAuthenticationRepository()),
        userDataUseCase: UserDataUseCase = UserDataUseCase(userDataRepository: LollipopUserDataRepository()),
        resultUseCase: ResultUseCase = ResultUseCase(resultRepo: LollipopResultRepository()),
        onSignOut: @escaping () -> ()
    ) {
        self.onSignOut = onSignOut
        self._viewModel = StateObject(
            wrappedValue: ProfileViewModel(
                authenticationUseCase: authenticationUseCase,
                userDataUseCase: userDataUseCase,
                resultUseCase: resultUseCase
            )
        )
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                profileBasicInfo
                
                graphInfo
                
                statusInfo
                
                logoutBtn
            }
            .padding(.horizontal)
        }
        .navigationTitle("プロフィール")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadUserData()
        }
    }
    
    
    @ViewBuilder
    private var profileBasicInfo: some View {
        AsyncImage(url: URL(string: viewModel.userData?.photoURL ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(300)
        } placeholder: {
            Image(.profilePic)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(300)
        }
        
        
        Text(viewModel.userData?.displayName ?? "")
            .font(.title.bold())
        
        Text(verbatim: viewModel.userData?.email ?? "")
            .foregroundStyle(.gray)
    }
    
    
    @ViewBuilder
    private var graphInfo: some View {
        Text("学業進捗")
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
        
        Chart(data) { dataPoint in
            BarMark(
                x: .value("月", dataPoint.month),
                y: .value("スコア", dataPoint.averageScore)
            )
            
            .foregroundStyle(
                LinearGradient(
                    colors: [.secAccent.opacity(1), .accent.opacity(0.8), .accent.opacity(0.8)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .cornerRadius(5)
        }
        .padding(30)
        .chartScrollableAxes(.horizontal)
        .chartXScale(range: .plotDimension(padding: 20))
        .chartXVisibleDomain(length: 12 * 30 * 24 * 60 * 60)
        .chartXAxis {
            AxisMarks(preset: .aligned, values: data.map { $0.month }) { date in
                AxisValueLabel(format: .dateTime.month(.defaultDigits))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 240)
        .chartYScale(domain: 0...120)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2)

        HStack {
            Circle()
                .fill(.accent)
                .frame(width: 10, height: 10)
            Text("平均スコア")
                .font(.caption)
        }
        .task {
            await viewModel.loadResults(year: 2025)
        }
    }
    
    
    @ViewBuilder
    private var statusInfo: some View {
        HStack {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(.secAccent)
                
                Text("13")
                    .font(.headline)
                
                Text("完了した課題")
                    .fontWeight(.thin)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.gray.opacity(0.2))
            )
            .padding(.horizontal)
            
            VStack(spacing: 10) {
                Image(systemName: "star.hexagon")
                    .font(.title2)
                    .foregroundStyle(.accent)
                
                Text("80")
                    .font(.headline)
                
                Text("平均スコア")
                    .fontWeight(.thin)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.gray.opacity(0.2))
            )
            .padding(.horizontal)
        }
    }
    
    
    @ViewBuilder
    private var logoutBtn: some View {
        Button {
            viewModel.signOut()
            onSignOut()
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                
                Text("ログアウト")
                
            }
            .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .stroke(lineWidth: 2)
                .foregroundStyle(.gray.opacity(0.2))
        )
        .padding(.top, 50)
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            authenticationUseCase: AuthenticationUseCase(authenticationRepository: TestAuthenticationRepository()),
            userDataUseCase: UserDataUseCase(userDataRepository: TestUserRepository()),
            resultUseCase: ResultUseCase(resultRepo: TestResultRepository())
            ,onSignOut: {}
        )
    }
}
