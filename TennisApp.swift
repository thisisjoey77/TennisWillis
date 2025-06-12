import SwiftUI

@main
struct TennisApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                TeamDataManager.save(Teams)
                GameDataManager.save(Games)
            }
        }
    }
}
