import SwiftUI

struct ContentView: View {
    @State private var showingSplash = true
    
    var body: some View {
        if showingSplash {
            SplashView()
                .onAppear {
                    // Auto-hide splash after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSplash = false
                        }
                    }
                }
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}
