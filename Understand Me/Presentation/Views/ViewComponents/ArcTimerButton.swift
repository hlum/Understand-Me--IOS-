//
//  ArcTimerButton.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/27.
//


import SwiftUI
import Combine

/// A reusable button that visually fills an arc into a complete circle over a specified duration.
struct ArcTimerButton: View {
    @Binding var progress: Double

    // MARK: - Configuration
    let duration: TimeInterval
    var lineWidth: CGFloat = 12
    var size: CGFloat = 120
    var label: String?
    var accentColor: Color = .blue
    var warningColor: Color = .red
    var warningThreshold: Int = 3
    var onComplete: (() -> Void)? = nil
    var onTick: ((Int) -> Void)? = nil
    
    // MARK: - State
    @State private var isRunning = false
    @State private var timerCancellable: Cancellable? = nil
    @State private var breathScale: CGFloat = 1.4
    
    // MARK: - Computed Properties
    private var remainingSeconds: Int {
        max(0, Int(ceil((1 - progress) * duration)))
    }
    
    private var isWarning: Bool {
        remainingSeconds <= warningThreshold && remainingSeconds > 0
    }
    
    private var currentColor: Color {
        isWarning ? warningColor : accentColor
    }
    
    private var animatedSize: CGFloat {
        let baseSize = size
        let breathOffset: CGFloat = isWarning ? 15 : 5
        return baseSize + (breathScale * breathOffset)
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: handleTap) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .foregroundColor(currentColor.opacity(0.12))
                
                // Progress arc
                Circle()
                    .trim(from: CGFloat(progress), to: 1)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .foregroundColor(currentColor)
                    .rotationEffect(.degrees(-90))
                
                // Center content
                VStack(spacing: 4) {
                    if let label {
                        Text(label)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    } else {
                        
                        Text("\(remainingSeconds)")
                            .font(.system(size: isWarning ? 28 : 22, weight: .medium))
                            .foregroundColor(isWarning ? warningColor : .primary.opacity(0.8))
                    }
                }
            }
            .frame(width: size, height: size)
            .scaleEffect(breathScale)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label ?? ""), \(remainingSeconds) seconds remaining")
        .accessibilityHint("Tap to start timer")
        .onAppear {
            startBreathingAnimation()
            startTimer()
        }
        .onDisappear(perform: cleanup)
        .onChange(of: remainingSeconds) { _, newValue in
            onTick?(newValue)
        }
    }
    
    // MARK: - Actions
    private func handleTap() {
        stopTimer()
        progress = 0.0
        isRunning = true
        startTimer()
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        stopTimer()
        
        let tickInterval: TimeInterval = 0.016 // ~60fps for smooth animation
        var elapsed: TimeInterval = 0
        
        timerCancellable = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                elapsed += tickInterval
                let newProgress = min(1.0, elapsed / duration)
                progress = newProgress
                
                if newProgress >= 1.0 {
                    completeTimer()
                }
            }
    }
    
    private func completeTimer() {
        stopTimer()
        isRunning = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onComplete?()
            startTimer()
        }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func cleanup() {
        stopTimer()
    }
    
    // MARK: - Animations
    private func startBreathingAnimation() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            breathScale = 1.05
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var progress: Double = 0.0
    VStack(spacing: 40) {
        ArcTimerButton(
            progress: $progress, duration: 5,
            lineWidth: 14
        ) {            print("Completed!")
        }
        
//        ArcTimerButton(
//            duration: 10,
//            lineWidth: 10,
//            size: 100,
//            label: "Start",
//            accentColor: .green,
//            warningColor: .orange
//        ) {
//            print("Done!")
//        } onTick: { remaining in
//            print("Remaining: \(remaining)")
//        }
    }
}
