import SwiftUI
import PDFKit

struct RankView: View {
    @State private var selectedSort: String? = nil
    @State private var referer: String = (Array(Teams.keys).count != 0) ? Array(Teams.keys)[0] : "" // Default to Varsity Team

    let teamOptions = Array(Teams.keys);
    let sortOptions = ["Matches\nWon", "Matches\nLost", "Win Loss\nRatio", "Games\nWon", "Points\nWon"]
    let sortOptAbrv = ["MWIN", "MLOS", "WLR", "GWIN", "PWIN"]
    
    @State private var matchWArr: [String: Int] = [:]
    @State private var matchLArr: [String: Int] = [:]
    @State private var matchRArr: [String: Double] = [:]
    @State private var gameArr: [String: Int] = [:]
    @State private var pointArr: [String: Int] = [:]
    
    init() {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 2/255, green: 40/255, blue: 141/255, alpha: 1.0)
            
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor.white],
                for: .selected
            )
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor(red: 2/255, green: 40/255, blue: 141/255, alpha: 1.0)],
                for: .normal
            )
        }

    var body: some View {
        VStack(spacing: 0) {

            Picker("", selection: $referer) {
                ForEach(teamOptions, id: \.self) { option in
                    Text(option)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 10)
            .onChange(of: referer) { newValue in
                renewSpecArray(referer: newValue)
            }

            HStack(alignment: .top) {
                Text("Player")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    .cornerRadius(12)
                ForEach(Array(sortOptAbrv.enumerated()), id: \.element) {(index, element) in
                    Button(action: {
                        selectedSort = sortOptions[index].replacingOccurrences(of: "\n", with: " ")
                    }) {
                        Text(element)
                            .fontWeight(.semibold)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundColor(Color(red: 2 / 255, green:40 / 255, blue: 141 / 255))
                            .background(selectedSort == sortOptions[index].replacingOccurrences(of: "\n", with: " ") ? Color.blue.opacity(0.3) : Color.clear)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)

            let players = sortedPlayers()
            ForEach(players, id: \.self) { player in
                HStack(alignment: .top) {
                    Text(player)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)
                        .padding(.vertical, 8)
                    Text("\(matchWArr[player] ?? 0)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    Text("\(matchLArr[player] ?? 0)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    Text(String(format: "%.3f", Double(matchRArr[player] ?? 0)))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    Text("\(gameArr[player] ?? 0)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    Text("\(pointArr[player] ?? 0)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal, 10)
            }
            NavigationStack {
                NavigationLink(
                    destination: HistoryView()) {
                        Text("View History")
                            .foregroundColor(Color(red: 2 / 255, green:40 / 255, blue: 141 / 255))
                            .fontWeight(.semibold)
                            .padding(.vertical, 10)
                    }
                    .padding(.horizontal)
            }
            Button(action: {
                let pdfDocument = PDFDocument()
                    let pdfPage = createPDFPage(from: Teams[referer] ?? [], ref: referer)
                    pdfDocument.insert(pdfPage, at: 0)

                    if let documentData = pdfDocument.dataRepresentation() {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("TennisStats.pdf")
                        do {
                            try documentData.write(to: tempURL)
                            
                            // Present Document Picker to export the file
                            let picker = UIDocumentPickerViewController(forExporting: [tempURL])
                            picker.shouldShowFileExtensions = true
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let root = scene.windows.first?.rootViewController {
                                root.present(picker, animated: true)
                            }
                        } catch {
                            print("Could not save PDF temporarily: \(error)")
                        }
                    }
            })
            {
                Text("Export Data")
                .foregroundColor(Color(red: 2 / 255, green:40 / 255, blue: 141 / 255))
                .fontWeight(.semibold)
                .padding(.vertical, 10)
            }
        }
        .position(x:200, y:250)
        .onAppear {
            renewSpecArray(referer: referer)
        }
    }
    
    func createPDFPage(from stats: [playerIcon], ref: String) -> PDFPage {
        let pageWidth = 1000.0  // 8.5 inches
        let pageHeight = 800.0 // 11 inches
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        UIGraphicsBeginImageContext(pageRect.size)
        guard let context = UIGraphicsGetCurrentContext() else { fatalError() }

        // Draw background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(pageRect)

        // Draw title
        let title = "Tennis Match Stats"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24)
        ]
        title.draw(at: CGPoint(x: 72, y: 40), withAttributes: titleAttributes)

        // Draw table headers
        let headers = ["Player", "MWIN", "MLOS", "WLR", "GWIN", "PWIN"]
        let startX: CGFloat = 72
        var startY: CGFloat = 100
        let columnWidth: CGFloat = 120
        let rowHeight: CGFloat = 30

        for (i, header) in headers.enumerated() {
            header.draw(at: CGPoint(x: startX + CGFloat(i) * columnWidth, y: startY),
                        withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        }

        // Draw table rows
        startY += rowHeight
        for stat in stats {
            let row = [
                stat.title,
                "\(stat.matchWon)",
                "\(stat.matchLost)",
                String(format: "%.3f", ((stat.matchWon + stat.matchLost) == 0 ? 0.0 : (Double(stat.matchWon) / Double(stat.matchWon + stat.matchLost)))),
                "\(stat.gamesWon)",
                "\(stat.pointsWon)"
            ]
            
            for (i, value) in row.enumerated() {
                value.draw(at: CGPoint(x: startX + CGFloat(i) * columnWidth, y: startY),
                           withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            }
            startY += rowHeight
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let pdfPage = PDFPage(image: image)!
        return pdfPage
    }
    
    /**
     
     */

    func renewSpecArray(referer: String) {
        matchWArr.removeAll()
        matchLArr.removeAll()
        matchRArr.removeAll()
        gameArr.removeAll()
        pointArr.removeAll()

        if let teamArr = Teams[referer] {
            for player in teamArr {
                matchWArr[player.title] = player.matchWon
                matchLArr[player.title] = player.matchLost
                matchRArr[player.title] = (player.matchWon + player.matchLost) == 0
                    ? 0.0
                : (Double(player.matchWon) / Double(player.matchWon + player.matchLost))
                gameArr[player.title] = player.gamesWon
                pointArr[player.title] = player.pointsWon
            }
        }
    }

    func sortedPlayers() -> [String] {
        let players = Array(matchWArr.keys)

        switch selectedSort {
        case "Matches Won":
            return players.sorted { (matchWArr[$0] ?? 0) > (matchWArr[$1] ?? 0) }
        case "Matches Lost":
            return players.sorted { (matchLArr[$0] ?? 0) > (matchLArr[$1] ?? 0) }
        case "Win Loss Ratio":
            return players.sorted { (matchRArr[$0] ?? 0) > (matchRArr[$1] ?? 0) }
        case "Games Won":
            return players.sorted { (gameArr[$0] ?? 0) > (gameArr[$1] ?? 0) }
        case "Points Won":
            return players.sorted { (pointArr[$0] ?? 0) > (pointArr[$1] ?? 0) }
        default:
            return players
        }
    }
}

struct HistoryView : View {
    var body: some View {
        VStack(alignment: .center, spacing:0) {
            ForEach(0..<Games.count) { i in
                VStack(spacing: 0) {
                    Text("Date: " + String(Games[i].gameDate.year) + "/\(Games[i].gameDate.month)/\(Games[i].gameDate.day)")
                        .frame(width: CGFloat(150 + Games[i].setType * 60), height: 40)
                            .border(Color.black)
                    HStack(spacing:0) {
                        Text("Player")
                            .frame(width: 150, height: 40)
                            .border(Color.black)
                        ForEach(1...Games[i].setType, id: \.self) { set in
                            Text("Set \(set)")
                                .frame(width: 60, height: 40)
                                .bold()
                                .border(Color.black)
                        }
                    }
                    ForEach(0..<2) { j in
                        PastPlayerRow(
                            targetPlayer: Games[i].stats[j],
                            isWinner: (Games[i].winnerIndex==j) ? true : false
                        )
                    }
                    
                }.padding()
            }
        }
    }
}

struct PastPlayerRow: View {
    let targetPlayer : PlayerScore
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing:0) {
            HStack(spacing:0) {
                Text(targetPlayer.name)
                        .frame(width: 150, height: 40)
                        .bold()
                        .border(Color.black)
                        .background(isWinner==true ? Color(red: 2 / 255, green:40 / 255, blue: 141 / 255) : Color.white)
                        .foregroundColor(isWinner==true ? Color.white : Color.black)
                    
                    ForEach(targetPlayer.setScores, id: \.self) { set in
                        Text("\(set)")
                            .frame(width: 60, height: 40)
                            .border(Color.black)
                            .background(isWinner==true ? Color(red: 2 / 255, green:40 / 255, blue: 141 / 255) : Color.white)
                            .foregroundColor(isWinner==true ? Color.white : Color.black)
                    }
            }
        }
    }
}

#Preview {
    RankView()
}
