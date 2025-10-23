//
//  ProfileView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/09.
//

import SwiftUI
import Charts


struct ProfileView: View {
    @State private var averageResultsPerMonth: [AverageResultPerMonth] = AverageResultPerMonth.getDummy()
    
    // ユーザがドラッグて選択した日付
    @State private var rawSelectedDate: Date? = nil
    
    // 選択された月の平均結果
    var selectedAverageResult: AverageResultPerMonth? {
        // ドラッグで選択されたに付けがなければ、resultも空
        guard let rawSelectedDate else { return nil }
        
        let calendar = Calendar.current
        
        // 平均結果配列から、選択された月と同じ月の日付を持つデータを返す
        return averageResultsPerMonth.first { calendar.isDate($0.month, equalTo: rawSelectedDate, toGranularity: .month)}
    }
    
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
        
        
        Chart {
            // 選択された月の平均スコアを示すルールマーク
            if let selectedAverageResult {
                RuleMark(x: .value("選択された月", selectedAverageResult.month, unit: .month))
                    .foregroundStyle(.secondary.opacity(0.5))
                    .annotation(position: .top, overflowResolution:.init(x: .fit(to: .chart), y: .disabled)){
                        
                        VStack {
                            Text("\(Int(selectedAverageResult.averageScore))点")
                                .font(.subheadline)
                            Text(selectedAverageResult.month, format: .dateTime.month(.twoDigits).year())
                                .font(.system(size: 8))
                        }
                        .padding(5)
                        .background(.accent.opacity(0.5))
                        .cornerRadius(10)
                    }
            }
            
            
            ForEach(averageResultsPerMonth) { dataPoint in
                // ユーザがグラフをドラッグして選択しているかどうか
                let userDraggingGraph = selectedAverageResult != nil
                let isSelectedBar = selectedAverageResult?.month == dataPoint.month
                
                
                BarMark(
                    x: .value("月", dataPoint.month, unit: .month),
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
                // 選択されているバーのみ不透明にする
                .opacity(!userDraggingGraph || isSelectedBar ? 1 : 0.3)
            }
        }
        .chartYScale(domain: 0...120)
        .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
//                    .chartScrollableAxes(.horizontal)
        .chartXScale(range: .plotDimension(padding: 10))
//        .chartXVisibleDomain(length: 12 * 30 * 24 * 60 * 60)
//        .chartXAxis {
//            AxisMarks(values: averageResultsPerMonth.map { $0.month }) { date in
//                AxisValueLabel(format: .dateTime.month(.defaultDigits))
//            }
//        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in  // Changed to use .stride
                if let date = value.as(Date.self) {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits), centered: true)
                }
            }
        }

        .chartYAxis {
            AxisMarks { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                AxisValueLabel()
            }
        }
        .padding(30)
        .frame(height: 280)
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
