import SwiftUI

@main
struct TennisApp: App {
    init() {
            UIView.appearance().overrideUserInterfaceStyle = .light
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
