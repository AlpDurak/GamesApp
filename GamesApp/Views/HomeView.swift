//
//  ContentView.swift
//  GamesApp
//
//  Created by Alp on 19.04.2023.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.isSearching) private var isSearching: Bool
    @Environment(\.dismissSearch) private var dismissSearch
    @StateObject var vM = HomeViewModel()
    @State var searchQuery = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vM.games, id: \.self) { game in
                    let ImageURL = URL(string: "https:\(game.url)")
                    NavigationLink(destination: GameView(game: game)) {
                        HStack(spacing: 15) {
                            AsyncImage(url: ImageURL) { returnedImage in
                                returnedImage
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 60, height: 60)
                                    .background(Color("SoftBG"))
                            }.cornerRadius(10)

                            Text(game.game.name)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
            }
            .navigationTitle("Games")
            .onAppear {
                Task {
                    await vM.fetch()
                }
            }
            .searchable(text: $searchQuery)
            .onChange(of: searchQuery) { query in
                if query.isEmpty && !isSearching && vM.isSearching {
                    Task {
                        vM.stopSearching()
                        await vM.fetch()
                    }
                } else {
                    Task {
                        vM.startSearching()
                        await vM.search(with: query)
                    }
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
