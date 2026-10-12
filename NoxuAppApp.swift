import SwiftUI
import SwiftData

@main
struct NoxuAppApp: App {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("userCredits") private var userCredits = 0
    
    @State private var showSplash = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    ContentView()
                }
            }
            .environment(\.locale, .init(identifier: "en"))
            .id("fixed-english-language")
            .onAppear {
                handleLaunch()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func handleLaunch() {
        NotificationManager.instance.requestAuthorization()
        if isFirstLaunch {
            userCredits = 100
            isFirstLaunch = false
        }
    }
}

    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background: print("App background")
        case .inactive: print("App inactive")
        case .active: print("App active")
        @unknown default: break
        }
    }
