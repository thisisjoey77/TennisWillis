import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        NavigationLink(
                            destination: ModTeamView().navigationBarBackButtonHidden(true)) {
                                Text("Edit")
                                    .foregroundColor(Color(red: 2 / 255, green: 40 / 255, blue: 141 / 255))
                            }
                            .padding(.horizontal)
                    }

                    ForEach(Array(Teams.keys), id: \.self) { teamName in
                        if let varsityArr = Teams[teamName] {
                            VStack(alignment: .leading) {
                                NavigationLink(
                                    destination: DetailGameView(referer: teamName).navigationBarBackButtonHidden(true)) {
                                        Text(teamName)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(.horizontal)
                                            .foregroundColor(Color(red: 2 / 255, green: 40 / 255, blue: 141 / 255))
                                            .frame(maxWidth: .infinity, alignment: .leading)
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
    @State private var finishedEditing = false
    @State private var editNames = false
    @State private var newName = ""
    
    var body: some View {
        if(finishedEditing) {
            ContentView().navigationBarBackButtonHidden(true)
        }
        else {
            
            let keys = Array(Teams.keys)
            VStack() {
                NavigationView {
                    List {
                        ForEach(keys,id: \.self) { key in
                            Text(key)
                        }.onDelete {indexSet in
                            for index in indexSet {
                                let remKey = keys[index];
                                Teams.removeValue(forKey: remKey);
                            }
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
                                Teams[newName] = [];
                                newName = "" // Clear the input field
                            }
                        }) {
                            Text("Add Team")
                        }
                    }
                }.frame(maxHeight: 200) // Limit the height of the form to 200 points or any value you desire.
                    .padding(.bottom)
            }
            HStack {
                Button(action: {
                    finishedEditing = true  // Trigger navigation
                    TeamDataManager.save(Teams)
                }) {
                    Text("Make changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }.padding(.horizontal)
        }
    }
    
}

struct DetailGameView : View {
    
    @State private var finishedEditing = false
    @State private var editNames = false
    @State private var newName = ""
    let referer: String
    
    var body: some View {
        if(finishedEditing) {
            ContentView().navigationBarBackButtonHidden(true)
            
        }
        /*
        if(editNames) {
            ModNameView().navigationBarBackButtonHidden(true)
        }*/
        else {
            VStack() {
                VStack() {
                    NavigationView {
                        List {
                            ForEach(Teams[referer] ?? [],id: \.id) { (player) in
                                Text(player.title)
                            }.onDelete { (indexSet) in
                                Teams[referer]?.remove(atOffsets: indexSet)
                                renewIds(ref:referer)
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
                                let sz:Int = Teams[referer]?.count ?? 0;
                               // print(newName);
                                Teams[referer]?.append(
                                    playerIcon(
                                        id: sz,
                                        title: newName,
                                        imageUrl: "person"
                                    )
                                )
                                newName = ""
                            }
                        }) {
                            Text("Add Name")
                        }
                    }
                }.frame(maxHeight: 200) // Limit the height of the form to 200 points or any value you desire.
                    .padding(.bottom)
                // Buttons
                HStack {
                    Button(action: {
                        TeamDataManager.save(Teams)
                        finishedEditing = true  // Trigger navigation
                    }) {
                        Text("Make changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }.padding(.horizontal)
            }
            }
        }
    }
    func renewIds(ref: String) {
        if Teams[ref] == nil {return}
        for i in 0...((Teams[ref]?.count ?? 1)-1) {
            Teams[ref]![i].id=i
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
    HomeView()
}

