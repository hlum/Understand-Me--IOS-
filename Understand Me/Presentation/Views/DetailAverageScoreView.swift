//
//  DetailAverageScoreView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/21.
//

import SwiftUI


struct DetailAverageScoreView: View {
    @StateObject private var viewModel: DetailAverageScoreViewModel
    
    
    init(
        averageScoreRepository: AverageScoreRepository = LollipopAverageScoreRepository(),
        authenticationRepository: AuthenticationRepository = FirebaseAuthenticationRepository()
    ) {
        _viewModel = .init(
            wrappedValue: DetailAverageScoreViewModel(
                averageScoreUseCase: AverageScoreUseCase(repository: averageScoreRepository),
                authenticationUseCase: AuthenticationUseCase(authenticationRepository: authenticationRepository)
            )
        )
    }
    var body: some View {
        ScrollView {
            ForEach(viewModel.averageScoresPerClass) { averageScorePerClass in
                averageScoreForClassItem(className: averageScorePerClass.className, averageScore: averageScorePerClass.averageScore, finishedHomeworkCount: averageScorePerClass.finishedHomeworkCount, maxHomeworkCount: averageScorePerClass.totalHomeworkCount)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("各科目の平均スコア")
        .navigationBarTitleDisplayMode(.inline)
        .alert (isPresented: $viewModel.showAlert){
            Alert(title: Text("エラー"),message: Text(viewModel.alertMessage))
        }
        .task {
            await viewModel.loadAverageScoresPerClass()
        }
        .refreshable {
            await viewModel.loadAverageScoresPerClass()
        }
    }
    
    @ViewBuilder
    private func averageScoreForClassItem(className: String, averageScore: Int, finishedHomeworkCount: Int, maxHomeworkCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "graduationcap.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [.secAccent, .accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(className)
                    .font(.title3.bold())
                
                Spacer()
            }
            
            // Stats Cards
            HStack(spacing: 12) {
                // Average Score Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.hexagon")
                            .font(.title3)
                            .foregroundStyle(.accent)
                        
                        Text("平均点")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("\(averageScore)")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("点")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                
                // Homework Count Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secAccent)
                        
                        Text("課題数")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        
                        Text("\(finishedHomeworkCount)")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("/\(maxHomeworkCount)")
                            .font(.subheadline)
                        
                        Text("個")
                            .font(.subheadline)
                        
                    }
                    .foregroundStyle(.primary)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        DetailAverageScoreView(
            averageScoreRepository: TestAverageRepository(),
            authenticationRepository: TestAuthenticationRepository()
        )
    }
}
