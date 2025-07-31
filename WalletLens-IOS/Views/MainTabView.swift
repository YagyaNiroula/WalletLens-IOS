import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Transactions Tab
            TransactionsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .tag(1)
            
            // Camera Tab
            CameraView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
                .tag(2)
            
            // Receipt Tab
            ReceiptView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "doc.text.viewfinder")
                    Text("Receipt")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .environmentObject(viewModel)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
} 