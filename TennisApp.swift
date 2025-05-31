//
//  TennisApp.swift
//  Tennis
//
//  Created by Kim Joy on 12/22/24.
//

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
