import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 50
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient matching Android design
            LinearGradient(
                colors: [
                    Color(red: 0.59, green: 0.82, blue: 0.47), // #97D077
                    Color(red: 0.48, green: 0.71, blue: 0.36), // #7AB55C
                    Color(red: 0.35, green: 0.61, blue: 0.23)  // #5A9B3A
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    // App Title
                    Text("WalletLens")
                        .font(.system(size: 36, weight: .light, design: .default))
                        .foregroundColor(.black)
                        .opacity(titleOpacity)
                    
                    // App Subtitle
                    Text("Your Personal Finance Tracker")
                        .font(.system(size: 18, weight: .light, design: .default))
                        .foregroundColor(.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(subtitleOpacity)
                }
                .padding(.bottom, 48)
                
                // Let's Go Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isActive = true
                    }
                }) {
                    Text("Let's Go")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .opacity(buttonOpacity)
                .offset(y: buttonOffset)
                
                Spacer()
            }
            .padding(32)
        }
        .onAppear {
            startAnimations()
        }
        .fullScreenCover(isPresented: $isActive) {
            MainTabView()
        }
    }
    
    private func startAnimations() {
        // Fade in title and subtitle
        withAnimation(.easeInOut(duration: 1.0)) {
            titleOpacity = 1.0
            subtitleOpacity = 1.0
        }
        
        // Slide up and fade in button with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                buttonOffset = 0
                buttonOpacity = 1.0
            }
        }
        
        // Auto-navigate after 3 seconds (matching Android behavior)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isActive = true
            }
        }
    }
}

#Preview {
    SplashView()
} 