//
//  Selection.swift
//  TennisApp
//
import SwiftUI


//6:6 deuce 나중에 물어보기

//setMax is 6
let setMax : Int = 2
var winner : String = ""

struct PlayerScore {
    var name: String
    var setScores: [Int]
    var faults : Int = 0
    var doubleFaults : Int = 0
    var aces : Int = 0
    var winners : Int = 0
    var errors : Int = 0
    var violations : Int = 0
    var currentServer : Bool = false
    var setVictory: Int = 0
    var points : Int = 0
    var matchWon : Int = 0
    var matchLost : Int = 0
    var gamesWon : Int = 0
    var pointsWon : Int = 0

}

struct GameView: View {
    @State var chosen = "Varsity Team"
    @State var livePlayer1 : String = ""
    @State var livePlayer2 : String = ""
    @State var numberOfSets = 1
    @State var navigateToGame = false
    let rosterNames : [String] = Teams.map((\.key))
    
    init() {
         // Set background color of the selected segment
         UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 2/255, green: 40/255, blue: 141/255, alpha: 1.0)
         
         // Set text color for selected segment
         UISegmentedControl.appearance().setTitleTextAttributes(
             [.foregroundColor: UIColor.white],
             for: .selected
         )
         
         // Set text color for unselected segments
         UISegmentedControl.appearance().setTitleTextAttributes(
             [.foregroundColor: UIColor(red: 2/255, green: 40/255, blue: 141/255, alpha: 1.0)],
             for: .normal
         )
     }
    
    var body: some View {
        VStack(alignment:.center) {
            NavigationView {
                VStack(spacing: 30) {
                    Text("Match Setup")
                        .font(.title)
                        .bold()
                        .padding(.top, 20)
                    
                    // Roster selection
                    VStack {
                        Text("Selected Roster")
                            .font(.headline)
                        
                        Picker("Rosters", selection: $chosen) {
                            ForEach(rosterNames, id: \.self) { team in
                                Text(team).tag(team)
                            }
                        }
                        .onChange(of: chosen) { _ in
                            livePlayer1 = "";
                            livePlayer2 = "";
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    
                    // Player 1 Selection
                    VStack(alignment: .leading) {
                        Text("Select Player 1")
                            .font(.headline)
                        
                        Picker("Player 1", selection: $livePlayer1) {
                            ForEach(Teams[chosen] ?? [], id: \.id) { player in
                                Text(player.title).tag(player.title)
                                .foregroundColor(Color(red: 2 / 255, green:40 / 255, blue: 141 / 255))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .tint(Color(red: 2 / 255, green:40 / 255, blue: 141 / 255))
                    }
                    
                    // Player 2 Selection
                    VStack(alignment: .leading) {
                        Text("Select Player 2")
                            .font(.headline)
                        
                        Picker("Player 2", selection: $livePlayer2) {
                            ForEach(Teams[chosen] ?? [], id: \.id) {
                                player in
                                Text(player.title).tag(player.title)
                                .foregroundColor(Color(red: 2 / 255, green:40 / 255, blue: 141 / 255))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .tint(Color(red: 2 / 255, green:40 / 255, blue: 141 / 255))
                    }
                    
                    // Set Selection
                    VStack {
                        Text("Number of Sets")
                            .font(.headline)
                        
                        Picker("Sets", selection: $numberOfSets) {
                            Text("1 Set").tag(1)
                            Text("3 Sets").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    
                    // Start Match Button
                    if(livePlayer1.count>0 && livePlayer2.count>0) {
                        Button(action: {
                            navigateToGame = true
                        }) {
                            Text("Start Match")
                                .frame(width:200)
                        }
                        .frame(width: 200)
                        .padding()
                        .background(Color(red: 2 / 255, green:40 / 255, blue: 141 / 255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 30)
                    }
                    Spacer()
                    
                    // Navigation to Game View
                    NavigationLink(
                        destination: LiveView(
                            livePlayer1: $livePlayer1,
                            livePlayer2: $livePlayer2,
                            numberOfSets : $numberOfSets,
                            referer: $chosen)
                        .navigationBarBackButtonHidden(true),
                        isActive: $navigateToGame
                    ) {
                        EmptyView()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct LiveView: View {
    
    @State private var showScoringButtons = false
   // let tennispoints = [0, 15, 30, 40]
    @State private var tennispoints = [0, 15, 30, 40]
    @State private var winningplayer = 1
    @State private var currentSet = 0
    @State private var finished = false
    @State private var deuce = false
    @State private var advantagePlayer: Int? = nil
    @State private var serverSelected = false
    @State private var goToResults = false
    
    @State var playerData : [PlayerScore]
    
    @Binding var numberOfSets : Int
    @Binding var livePlayer1 : String
    @Binding var referer : String
    @Binding var livePlayer2 : String
    @State var currentServerIs1 : Bool
    
    let setSize : Int

    init(livePlayer1 : Binding<String>, livePlayer2 : Binding<String>, numberOfSets : Binding<Int>, referer: Binding<String>) {
        _livePlayer1 = livePlayer1
        _livePlayer2 = livePlayer2
        _numberOfSets = numberOfSets
        _referer = referer
        setSize = numberOfSets.wrappedValue
        _currentServerIs1 = State(initialValue: true)
        _playerData = State(initialValue: [
            PlayerScore(
                name: livePlayer1.wrappedValue,
                setScores : Array(repeating:0,count:setSize),
                faults : 0,
                doubleFaults : 0,
                aces : 0,
                winners : 0,
                errors : 0,
                violations : 0,
                currentServer : true,
                setVictory: 0,
                points : 0,
                matchWon : 0,
                matchLost: 0,
                gamesWon : 0,
                pointsWon : 0
            ),
            PlayerScore(
                name: livePlayer2.wrappedValue,
                setScores : Array(repeating:0,count:setSize),
                faults : 0,
                doubleFaults : 0,
                aces : 0,
                winners : 0,
                errors : 0,
                violations : 0,
                currentServer : false,
                setVictory: 0,
                points : 0,
                matchWon : 0,
                matchLost: 0,
                gamesWon : 0,
                pointsWon : 0
            )
        ])
    }
    
    var body: some View {
        if(goToResults) {
            GameAnalysisView(PStat1: playerData[0],
                             PStat2: playerData[1],
                             referer: referer,
                             winner: (playerData[1].setVictory > numberOfSets/2) ? playerData[1].name : playerData[0].name)
            .navigationBarTitle("", displayMode : .large).navigationBarBackButtonHidden(true)
        }
        else {
            GeometryReader { geo in
                // Tennis Score Table
                VStack(alignment:.center,spacing: 10) {
                        HStack {
                            Text("").frame(width: 100)
                            Text("Points").frame(width: 80).bold()
                            ForEach(1...setSize, id: \.self) { set in
                                Text("Set \(set)").frame(width: 60).bold()
                            }
                        }
                        
                        // Highlight Player 1 if currentServerIs1 is true
                        PlayerRow(
                            targetPlayer : playerData[0],
                            playerPoints: displayPoints(for:0)
                        )
                        
                        // Highlight Player 2 if currentServerIs1 is false
                        PlayerRow(
                            targetPlayer : playerData[1],
                            playerPoints: displayPoints(for:1)
                        )
                    
                }
                .frame(alignment:.top)
                .border(Color.gray)
                .position(
                    x: geo.size.width / 2,
                    y: geo.size.height/4
                )
            }
            .frame(alignment:.top)
        }
        if(!finished) {
            if !serverSelected {
                GeometryReader { geo in
                    VStack {
                        Text("Who serves first?").font(.title2)
                            .padding(.bottom, 20)
                        
                        HStack(spacing:0) {
                            Button(action: {
                                currentServerIs1 = true
                                serverSelected = true
                            }) {
                                Text("\(playerData[0].name)")
                                    .frame(width: 201, height: 500)
                            }
                            .playerButtonStyle(color: Color(red: 30 / 255, green:154 / 255, blue: 205 / 255))
                            
                            
                            Button(action: {
                                currentServerIs1 = false
                                serverSelected = true
                            }) {
                                Text("\(playerData[1].name)")
                                    .frame(width: 201, height: 500)
                            }
                            .playerButtonStyle(color: Color(red: 231 / 255, green:110 / 255, blue: 36 / 255))
                        }
                    }
                    .contentShape(Rectangle())
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height - 250
                    )
                }
            }
            else {
                ZStack {
                    GeometryReader { geo in
                        Group {
                            if showScoringButtons {
                                ScoringButtons(
                                    playerStats: $playerData,
                                    winningplayer: $winningplayer,
                                    scoreAction: handleScore,
                                    skipAction: skipScore
                                )
                            }
                            else {
                                PlayerSelection(
                                    showScoringButtons: $showScoringButtons,
                                    currentServerIs1: $currentServerIs1,
                                    playerStats: $playerData,
                                    winningplayer: $winningplayer
                                )
                            }
                        }
                        .animation(.easeInOut, value: showScoringButtons)
                        .position(
                            x: geo.size.width / 2,
                            y: geo.size.height - 250
                        )
                    }
                }
            }
        }
        else if(goToResults==false) {
            Button(action: {
                goToResults = true  // Trigger navigation
            }) {
                Text("Results")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
    func setServerColor() {
        
    }
    // Handle Scoring Logic
    func handleScore() {
        if deuce {
            handleDeuceScoring()
        } else {
            normalScoring()
        }
        showScoringButtons = false
    }
    
    func skipScore() {
        showScoringButtons = false
    }

    func normalScoring() {
        if playerData[winningplayer].points <= 3 {
            playerData[winningplayer].points += 1;
        }
        if playerData[winningplayer].points > 3 && playerData[abs(winningplayer-1)].points<3 {
            playerData[winningplayer].points += 1;
            winGame(for: winningplayer)
        }
        else if (playerData[abs(winningplayer-1)].points == playerData[winningplayer].points &&
                 playerData[winningplayer].points>=3) {
            deuce = true;
        }
    }

    func handleDeuceScoring() {
        playerData[winningplayer].points += 1;
        
        advantagePlayer = nil
        if(playerData[winningplayer].points !=
           playerData[abs(winningplayer-1)].points)
        {
            advantagePlayer = playerData[winningplayer].points > playerData[abs(winningplayer-1)].points ? winningplayer : abs(winningplayer-1)
        }
        
        if(advantagePlayer != nil &&
           abs(playerData[winningplayer].points - playerData[abs(winningplayer-1)].points)>1) {
            winGame(for: advantagePlayer ?? 0)
        }
    }
    
    //goes to resetPoints
    func winGame(for player: Int) {
        playerData[player].setScores[currentSet] += 1
        playerData[player].gamesWon += 1
        if(playerData[player].setScores[currentSet]==setMax) {
            //check if 부계승
            playerData[player].setVictory += 1
            if(playerData[player].setVictory > numberOfSets/2) {
                //abort
                playerData[winningplayer].matchWon += 1;
                playerData[abs(winningplayer-1)].matchLost += 1;
                winner = playerData[player].name
                finished = true
            }
            else {
                currentSet += 1
            }
        }
        resetPoints()
    }
    
    //resets to 0:0
    func resetPoints() {
        playerData[0].points = 0;
        playerData[1].points = 0;
        deuce = false
        advantagePlayer = nil
        currentServerIs1 = !currentServerIs1
    }

    func displayPoints(for player: Int) -> String {
        if deuce {
            if advantagePlayer == player {
                return "Ad"
            } else {
                return "40"
            }
        }
        else {
            return "\(tennispoints[(playerData[player].points)])"
        }
    }
}

struct GameAnalysisView: View {
    
    let PStat1: PlayerScore
    let PStat2: PlayerScore
    let referer: String
    let winner : String
    
    @State private var navigateToHome = false  // Track navigation
    
    var body: some View {
        if(!navigateToHome) {
            NavigationStack {
                VStack(alignment: .leading) {
                    Text("Match won by \(winner)")
                        .font(.title)
                        .bold()
                        .padding(.top, 20)
                        .padding()
                    Text("Game Analysis")
                        .font(.title)
                        .bold()
                        .padding(.top, 20)
                        .padding()
                    
                    // Table Headers
                    HStack {
                        Text("Stats").bold().frame(width: 150, alignment: .leading)
                        Text(PStat1.name).bold().frame(width: 100)
                        Text(PStat2.name).bold().frame(width: 100)
                    }
                    Divider()
                    
                    // Table Rows
                    statRow(label: "Points Won", value1: "\(PStat1.pointsWon)", value2: "\(PStat2.pointsWon)")
                    statRow(label: "Sets Won", value1: "\(PStat1.setVictory)", value2: "\(PStat2.setVictory)")
                    //CHANGE
                    statRow(label: "Games Won", value1: "\(PStat1.gamesWon)", value2: "\(PStat2.gamesWon)")
                     
                    statRow(label: "Faults", value1: "\(PStat1.faults)", value2: "\(PStat2.faults)")
                    statRow(label: "Double Faults", value1: "\(PStat1.doubleFaults)", value2: "\(PStat2.doubleFaults)")
                    statRow(label: "Aces", value1: "\(PStat1.aces)", value2: "\(PStat2.aces)")
                    statRow(label: "Winners", value1: "\(PStat1.winners)", value2: "\(PStat2.winners)")
                    statRow(label: "Errors", value1: "\(PStat1.errors)", value2: "\(PStat2.errors)")
                    statRow(label: "Violations", value1: "\(PStat1.violations)", value2: "\(PStat2.violations)")
                    
                    Spacer()
                    
                    // Buttons
                    HStack {
                        Button(action: {
                            applyToPlayers(PStat: PStat1)
                            applyToPlayers(PStat: PStat2)
                            navigateToHome = true
                        }) {
                            Text("End Match")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }.padding(.horizontal)
                }.padding()
            }
        }
        else {
            ContentView().navigationBarBackButtonHidden(true)
        }
    }
    
    func applyToPlayers(PStat: PlayerScore) {
        if let index = Teams[referer]?.firstIndex(where: { $0.title == PStat.name}) {
            Teams[referer]?[index].faults += PStat.faults
            Teams[referer]?[index].matchWon += PStat.matchWon
            Teams[referer]?[index].matchLost += PStat.matchLost
            Teams[referer]?[index].doubleFaults += PStat.doubleFaults
            Teams[referer]?[index].aces += PStat.aces
                //player.wins += PStat.winners
            Teams[referer]?[index].violations += PStat.violations
            //matches woN, games won, points won
            Teams[referer]?[index].pointsWon += PStat.pointsWon
            Teams[referer]?[index].gamesWon += PStat.gamesWon
            Teams[referer]?[index].setsWon += PStat.setVictory
        }
    }
   
    // Function to create a table row
    func statRow(label: String, value1: String, value2: String) -> some View {
        HStack {
            Text(label).frame(width: 150, alignment: .leading)
            Text(value1).frame(width: 100)
            Text(value2).frame(width: 100)
        }
        .padding(.vertical, 2)
    }
}

// Player Row Component
struct PlayerRow: View {
    let targetPlayer : PlayerScore
    let playerPoints : String
    
    var body: some View {
        VStack {
            HStack {
                Text(targetPlayer.name)
                    .frame(width: 100)
                    .bold()
                
                Text("\(playerPoints)")
                    .frame(width: 80)
                
                ForEach(targetPlayer.setScores, id: \.self) { set in
                    Text("\(set)")
                        .frame(width: 60)
                }
            }
            .padding(5)
            .background(targetPlayer.currentServer ? Color.yellow.opacity(0.3) : Color.clear)  // Highlight serving player
            .cornerRadius(8)
        }
    }
}

struct ScoringButtons: View {
    @Binding var playerStats: [PlayerScore]
    @Binding var winningplayer: Int
    let scoreAction: () -> Void
    let skipAction: () -> Void
    
    var body: some View {
        VStack(spacing:0) {
            Text("How?")
                .font(.title3)
                .bold()
                .padding(.bottom, 10)
            
            VStack(spacing:0) {
                
                HStack(alignment:.top, spacing:0) {
                    VStack(alignment:.leading,spacing:0) {
                        // Player 1 Actions (Green Buttons)
                        Button(action: {
                            //default potential error?
                            playerStats[winningplayer].aces += 1
                            playerStats[winningplayer].pointsWon += 1
                            scoreAction()
                        }) {
                            Text("Ace")
                                .padding()
                                .frame(minWidth: 203)
                                .frame(minHeight: 225)
                                .background(Color(red: 0.2, green: 0.7, blue: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(0)
                        }.overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        
                        Button(action: {
                            playerStats[winningplayer].winners += 1
                            playerStats[winningplayer].pointsWon += 1
                            scoreAction()
                        }) {
                            Text("Winner")
                                .padding()
                                .frame(minWidth: 203)
                                .frame(minHeight: 225)
                                .background(Color(red: 0.2, green: 0.7, blue: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(0)
                        }.overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                    }
                    
                    VStack(alignment:.leading,spacing: 0) {
                        // Player 2 Actions (Red Buttons)
                        Button(action: {
                            playerStats[abs(winningplayer-1)].doubleFaults += 1
                            playerStats[winningplayer].pointsWon += 1
                            scoreAction()
                        }) {
                            Text("Double Fault")
                                .padding()
                                .frame(minWidth: 203)
                                .frame(minHeight: 150)
                                .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(0)
                        }.overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        
                        Button(action: {
                            playerStats[abs(winningplayer-1)].errors += 1
                            playerStats[winningplayer].pointsWon += 1
                            scoreAction()
                        }) {
                            Text("Unforced Error")
                                .padding()
                                .frame(minWidth: 203)
                                .frame(minHeight: 150)
                                .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(0)
                        }.overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        
                        Button(action: {
                            playerStats[abs(winningplayer-1)].violations += 1
                            playerStats[winningplayer].pointsWon += 1
                            scoreAction()
                        }) {
                            Text("Violation")
                                .padding()
                                .frame(minWidth: 203)
                                .frame(minHeight: 150)
                                .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(0)
                        } .overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        
                    }
                }
                Button(action: {
                    skipAction()
                }) {
                    Text("Revoke Point")
                        .padding(.horizontal)
                        .frame(minWidth: 420)
                        .frame(minHeight:110)
                        .background(Color(red: 231 / 255, green:109 / 255, blue: 36 / 255))
                        .foregroundColor(.white)
                        .cornerRadius(0)
                }
                .overlay(
                    Rectangle()
                        .stroke(Color.white,lineWidth:3)
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .contentShape(Rectangle())
        
    }
}


struct PlayerSelection: View {
    @Binding var showScoringButtons: Bool
    @Binding var currentServerIs1: Bool  // Bind current server to track faults
    @Binding var playerStats: [PlayerScore]
    @Binding var winningplayer: Int
    
    @State private var showFaultButton = true  // Control fault button visibility
    
    var body: some View {
        VStack(alignment: .center, spacing:0) {
            Text("Who won the point?")
                .padding()
            
            
            // Fault Button Logic (Track Fault for Server)
            if showFaultButton {
                HStack(spacing: 0) {
                    Button(action: {
                        showScoringButtons = true
                        showFaultButton = true
                        winningplayer = 0
                    }) {
                        Text("\(playerStats[0].name)")
                            .frame(width: 201, height: 400)
                    }
                    .gameButtonStyle(color: Color(red: 30 / 255, green:154 / 255, blue: 205 / 255))
                    
                    Button(action: {
                        showScoringButtons = true
                        showFaultButton = true
                        winningplayer = 1
                    }) {
                        Text("\(playerStats[1].name)")
                            .frame(width: 201, height: 400)
                    }
                    .gameButtonStyle(color: Color(red: 231 / 255, green:110 / 255, blue: 36 / 255))
                }
                Button(action: {
                    playerStats[(currentServerIs1) ? 0 : 1].faults += 1
                    showFaultButton = false
                }) {
                    Text("Fault")
                        .frame(width: 420, height: 100)
                }
                .faultButtonStyle(color: Color(red: 0.8, green: 0.2, blue: 0.2))
            }
            else {
                HStack(spacing: 0) {
                    Button(action: {
                        showScoringButtons = true
                        showFaultButton = true
                        winningplayer = 0
                    }) {
                        Text("\(playerStats[0].name)")
                            .frame(width: 201, height: 500)
                    }
                    .playerButtonStyle(color: Color(red: 30 / 255, green:154 / 255, blue: 205 / 255))
                    
                    Button(action: {
                        showScoringButtons = true
                        showFaultButton = true
                        winningplayer = 1
                    }) {
                        Text("\(playerStats[1].name)")
                            .frame(width: 201, height: 500)
                    }
                    .playerButtonStyle(color: Color(red: 231 / 255, green:110 / 255, blue: 36 / 255))
                }
            }
        }
        .padding(.top,50)
    }
}

// Button Style Modifier
extension View {
    func playerButtonStyle(color: Color) -> some View {
        self.frame(width: 201, height: 500)
            .background(color)
            .foregroundColor(.white)
            .contentShape(Rectangle())
    }
    func gameButtonStyle(color: Color) -> some View {
        self.frame(width: 201, height: 350)
            .background(color)
            .foregroundColor(.white)
            .contentShape(Rectangle())
    }
    func faultButtonStyle(color: Color) -> some View {
        self.frame(width: 420, height: 100)
            .background(color)
            .foregroundColor(.white)
            .contentShape(Rectangle())
    }
}

#Preview {
    GameView()
}
