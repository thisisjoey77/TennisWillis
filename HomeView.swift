import SwiftUI

struct TeamIdentifier: Identifiable {
    let id: String
    let name: String
    
    init(_ name: String) {
        self.id = name
        self.name = name
    }
}

struct HomeView: View {
    @EnvironmentObject var appData: AppData
    @State private var showEditTeams = false
    @State private var selectedTeamForEdit: TeamIdentifier? = nil

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showEditTeams = true
                        }) {
                            Text("Edit")
                                .foregroundColor(Color(red: 2 / 255, green: 40 / 255, blue: 141 / 255))
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showEditTeams) {
                            ModTeamView()
                                .environmentObject(appData)
                        }
                    }

                    // Use sorted keys for consistent order
                    ForEach(Array(appData.teams.keys.sorted()), id: \.self) { teamName in
                        if let varsityArr = appData.teams[teamName] {
                            VStack(alignment: .leading) {
                                Button(action: {
                                    selectedTeamForEdit = TeamIdentifier(teamName)
                                }) {
                                    Text(teamName)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                        .foregroundColor(Color(red: 2 / 255, green: 40 / 255, blue: 141 / 255))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                // Use .sheet(item:) for editing members, passing the correct team
                                .sheet(item: $selectedTeamForEdit) { team in
                                    DetailGameView(referer: team.name)
                                        .environmentObject(appData)
                                }

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(varsityArr, id: \.id) { player in
                                            PlayerView(player: player)
                                                .padding(.horizontal, 10)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct ModTeamView : View {
    @EnvironmentObject var appData: AppData
    @Environment(\.dismiss) var dismiss
    @State private var editNames = false
    @State private var newName = ""
    
    var body: some View {
        VStack() {
            NavigationView {
                // Use sorted keys for consistent order
                List {
                    ForEach(Array(appData.teams.keys.sorted()), id: \.self) { key in
                        Text(key)
                    }
                    .onDelete { indexSet in
                        // Always use a fresh sorted array for deletion
                        let sortedKeys = Array(appData.teams.keys.sorted())
                        let keysToRemove = indexSet.map { sortedKeys[$0] }
                        keysToRemove.forEach { key in
                            appData.teams.removeValue(forKey: key)
                        }
                        TeamDataManager.save(appData.teams)
                        GameDataManager.save(appData.games)
                    }
                }
            }
            Spacer()
            // Form to add a name
            Form {
                Section(header: Text("Add Team")) {
                    TextField("Enter name", text: $newName)
                    Button(action: {
                        if !newName.isEmpty {
                            appData.teams[newName] = []
                            newName = "" // Clear the input field
                            TeamDataManager.save(appData.teams)
                            GameDataManager.save(appData.games)
                        }
                    }) {
                        Text("Add Team")
                    }
                }
            }
            .frame(maxHeight: 200)
            .padding(.bottom)
        }
        HStack {
            Button(action: {
                TeamDataManager.save(appData.teams)
                GameDataManager.save(appData.games)
                dismiss()
            }) {
                Text("Make changes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}

struct DetailGameView : View {
    @EnvironmentObject var appData: AppData
    @Environment(\.dismiss) var dismiss
    @State private var editNames = false
    @State private var newName = ""
    let referer: String
    
    var body: some View {
        VStack() {
            VStack() {
                NavigationView {
                    List {
                        // Use the array as-is to preserve insertion order
                        ForEach(appData.teams[referer] ?? [], id: \.id) { (player) in
                            Text(player.title)
                        }
                        .onDelete { (indexSet) in
                            TeamDataManager.save(appData.teams)
                            GameDataManager.save(appData.games)
                            appData.teams[referer]?.remove(atOffsets: indexSet)
                            renewIds(ref: referer)
                        }
                    }
                }
            }
            Spacer()
            // Form to add a name
            Form {
                Section(header: Text("Add a Name")) {
                    TextField("Enter name", text: $newName)
                    Button(action: {
                        if !newName.isEmpty {
                            let sz = appData.teams[referer]?.count ?? 0
                            appData.teams[referer]?.append(
                                playerIcon(
                                    id: sz,
                                    title: newName,
                                    imageUrl: "person"
                                )
                            )
                            newName = ""
                            TeamDataManager.save(appData.teams)
                            GameDataManager.save(appData.games)
                        }
                    }) {
                        Text("Add Name")
                    }
                }
            }
            .frame(maxHeight: 200)
            .padding(.bottom)
            // Buttons
            HStack {
                Button(action: {
                    TeamDataManager.save(appData.teams)
                    GameDataManager.save(appData.games)
                    dismiss()
                }) {
                    Text("Make changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }
    }
    func renewIds(ref: String) {
        guard let count = appData.teams[ref]?.count else { return }
        for i in 0..<count {
            appData.teams[ref]![i].id = i
        }
    }
}

struct ModNameView : View {
    var body: some View {
        VStack {
            
        }
    }
}

#Preview {
    HomeView().environmentObject(AppData())
}

