import SwiftUI
import UIKit
import PDFKit
import Combine

struct playerIcon: Identifiable, Codable, Hashable {
    public var id: Int
    var title: String
    var imageUrl: String

    var matchWon: Int = 0
    var matchLost: Int = 0
    var gamesWon: Int = 0
    var pointsWon: Int = 0
    var faults: Int = 0
    var doubleFaults: Int = 0
    var aces: Int = 0
    var winners: Int = 0
    var errors: Int = 0
    var violations: Int = 0
    var setsWon: Int = 0
}

public struct date: Codable {
    var day : Int
    var month : Int
    var year : Int
}

public struct game: Codable {
    var winnerIndex: Int
    var players: [String]
    var gameDate : date
    var stats: [PlayerScore]
    var roster: String
    var setType: Int
}

enum BottomTab : String {
    case home
    case ranks
    case game
}

class AppData: ObservableObject {
    @Published var teams: [String: [playerIcon]]
    @Published var games: [game]

    init() {
        self.teams = TeamDataManager.load() ?? [:]
        self.games = GameDataManager.load() ?? []
    }
}

struct ContentView: View {
    @EnvironmentObject var appData: AppData
    @State var currentTab : BottomTab = .home

    var body: some View {
        TabView(selection: $currentTab) {
            NavigationStack {
                HomeView()
                    .environmentObject(appData)
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(BottomTab.home)

            NavigationStack {
                RankView()
                    .environmentObject(appData)
                    .navigationTitle("Ranks")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Ranks", systemImage: "trophy.fill")
            }
            .tag(BottomTab.ranks)

            NavigationStack {
                GameView()
                    .environmentObject(appData)
                    .navigationTitle("Games")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Games", systemImage: "tennisball.fill")
            }
            .tag(BottomTab.game)
        }
        .tint(Color(red: 2 / 255, green: 40 / 255, blue: 141 / 255))
        .onAppear {
            if let loaded = TeamDataManager.load() {
                appData.teams = loaded
            }
            if let loadedGames = GameDataManager.load() {
                appData.games = loadedGames
            }
        }
    }
}

struct PlayerView : View {
    let player: playerIcon
    var body : some View {
        VStack {
            Image(player.imageUrl)
                .resizable()
                .frame(width: 80, height: 90)
                .cornerRadius(12)
            Text(player.title)
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    ContentView()
}

import Foundation

class TeamDataManager {
    static let fileName = "teams_data.json"

    static func save(_ teams: [String: [playerIcon]]) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let encoded = try? JSONEncoder().encode(teams) {
            try? encoded.write(to: url)
        }
    }

    static func load() -> [String: [playerIcon]]? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([String: [playerIcon]].self, from: data) {
            return decoded
        }
        return nil
    }

    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

class GameDataManager {
    static let fileName = "game_history.json"

    static func save(_ teams: [game]) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let encoded = try? JSONEncoder().encode(teams) {
            try? encoded.write(to: url)
        }
    }

    static func load() -> [game]? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([game].self, from: data) {
            return decoded
        }
        return nil
    }

    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
