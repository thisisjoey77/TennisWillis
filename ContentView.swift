import SwiftUI
import UIKit
import PDFKit

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

public struct date {
    var day : Int
    var month : Int
    var year : Int
}

public struct game {
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

var Teams: [String: [playerIcon]] = [
            "Varsity Team": [
                playerIcon(id:0,title:"Joy Kim", imageUrl: "person"),
                playerIcon(id:1,title:"Juan Lim", imageUrl: "person"),
                playerIcon(id:2,title:"Victor Kim", imageUrl: "person"),
                playerIcon(id:3,title:"John Park", imageUrl: "person"),
                playerIcon(id:4,title:"Matthew Shim", imageUrl: "person"),
                playerIcon(id:5,title:"Junho Son", imageUrl: "person"),
                playerIcon(id:6,title:"James Kim", imageUrl: "person"),
            ],
            "JV Team": [
                playerIcon(id:0,title:"Ben Willis", imageUrl: "person"),
                playerIcon(id:1,title:"Eva Biggart", imageUrl: "person"),
                playerIcon(id:2,title:"Chris Reese", imageUrl: "person"),
                playerIcon(id:3,title:"Lloyd Baker", imageUrl: "person"),
                playerIcon(id:4,title:"Darrick Broudy", imageUrl: "person"),
                playerIcon(id:5,title:"Julie Park", imageUrl: "person"),
                playerIcon(id:6,title:"Michael Connor", imageUrl: "person"),
            ]
        ]

var Games : [game] = []

struct ContentView: View {
    @State var currentTab : BottomTab = .home
    @State var fullScreenVisible : Bool = false
    var body: some View {
        ZStack {
            
            //Color(red:232/255,green:225/255,blue:207/255)
            NavigationStack {
                ZStack {
                    TabView(selection : $currentTab) {
                        HomeView()
                            .tabItem {
                                Label( "Home", systemImage: "house")
                            }
                            .tag(BottomTab.home)
                        RankView()
                            .tabItem {
                                Label("Ranks", systemImage:"trophy.fill")
                            }
                            .tag(BottomTab.ranks)
                        GameView()
                            .tabItem {
                                Label("Games",systemImage:"tennisball.fill")
                            }
                            .tag(BottomTab.game)
                    }
                    .navigationTitle(currentTab.rawValue.capitalized)
                    .navigationBarTitleDisplayMode(.large)
                    .tint(Color(red: 2 / 255, green: 40 / 255, blue: 141 / 255))
                }
            }
        }
        .onAppear {
            if let loaded = TeamDataManager.load() {
                Teams = loaded
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
