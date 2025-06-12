import SwiftUI

@main
struct TennisApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appData = AppData()

    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                TeamDataManager.save(appData.teams)
                GameDataManager.save(appData.games)
            }
        }
    }
}
