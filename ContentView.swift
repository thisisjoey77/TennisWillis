//
//  ContentView.swift
//  Tennis
//
//  Created by Kim Joy and Lim Juan
//

import SwiftUI
import UIKit
import PDFKit

public struct playerIcon {
    var faults : Int = 0
    var doubleFaults : Int = 0
    var aces : Int = 0
    var errors : Int = 0
    var violations : Int = 0
    var matchWon : Int = 0
    var matchLost : Int = 0
    var setsWon : Int = 0
    var gamesWon : Int = 0
    var pointsWon : Int = 0
    var id : Int
    let title, imageUrl: String
}

enum BottomTab : String {
    case home
    case ranks
    case game
}

var Teams: [String: [playerIcon]] = [
            "Varsity Team": [
                playerIcon(id:0,title:"Marcus Ellison", imageUrl: "person"),
                playerIcon(id:1,title:"Natalie Chen", imageUrl: "person"),
                playerIcon(id:2,title:"Javier Morales", imageUrl: "person"),
                playerIcon(id:3,title:"Priya Desai", imageUrl: "person"),
                playerIcon(id:4,title:"Thomas Gallagher", imageUrl: "person"),
                playerIcon(id:5,title:"Amina Yusuf", imageUrl: "person"),
                playerIcon(id:6,title:"Caleb Montgomery", imageUrl: "person"),
            ],
            "JV Team": [
                playerIcon(id:0,title:"Sofia Petrov", imageUrl: "person"),
                playerIcon(id:1,title:"Liam ODonnel", imageUrl: "person"),
                playerIcon(id:2,title:"Mei Tanaka", imageUrl: "person"),
                playerIcon(id:3,title:"Lila Thornton", imageUrl: "person"),
                playerIcon(id:4,title:"Omar Al-Farsi", imageUrl: "person"),
                playerIcon(id:5,title:"Helena Duarte", imageUrl: "person"),
                playerIcon(id:6,title:"James Kim", imageUrl: "person"),
            ]
        ]

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
                }
            }
            .background(Color(red:232/255,green:225/255,blue:207/255))
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
