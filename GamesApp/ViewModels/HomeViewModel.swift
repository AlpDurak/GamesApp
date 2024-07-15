//
//  HomeViewModel.swift
//  GamesApp
//
//  Created by Alp on 19.04.2023.
//

import SwiftUI


struct CoverObject: Hashable, Codable {
    let id: Int
    let game: Game
    let url: String
}

struct Game: Hashable, Codable {
    let id: Int
    let follows: Int?
    let hypes: Int?
    let name: String
    let storyline: String?
    let summary: String?
    let url: String
    let cover: Int?
}

struct Cover: Hashable, Codable {
    let id: Int
    let url: String
}

struct CoverQuery: Hashable, Codable {
    let name: String
    let result: [Cover]
}

struct CreatePlaceHolder {
    let game = Game(id: 0, follows: 0, hypes: 0, name: "", storyline: "", summary: "", url: "", cover: 0)
    let coverObject = CoverObject(id: 0, game: Game(id: 0, follows: 0, hypes: 0, name: "", storyline: "", summary: "", url: "", cover: 0), url: "")
}

class HomeViewModel: ObservableObject {
    @Published var games: [CoverObject] = []
    @Published var isSearching: Bool = false
    
    func toggleSearching() { self.isSearching = !self.isSearching }
    func startSearching() { self.isSearching = true }
    func stopSearching() { self.isSearching = false }
    
    func fetch() async {
        let preferences = "f url,game.name,game.hypes,game.follows,game.storyline,game.url; w url !=n & game.follows !=n & game.storyline !=n & game.url !=n & game.hypes >= 100; l 20;"
        let requestHeader = CreateRequestHeader(path: "covers", preferences: preferences)
        
        let data = try? await MakeHTTPRequest(with: requestHeader, as: [CoverObject].self)
        
        DispatchQueue.main.async {
            self.games = data!
        }
    }
    
    func search(with searchQuery: String) async {
        
        // search for the games
        let searchPreferences = "f name,hypes,follows,cover,url,storyline,summary; w cover !=n & url !=n; search \"\(searchQuery)\";"
        let searchRequestHeader = CreateRequestHeader(path: "games", preferences: searchPreferences)
        
        let gameData = try? await MakeHTTPRequest(with: searchRequestHeader, as: [Game].self)
        
        if !gameData!.isEmpty {
            // create a preference string with requests for all the games covers
            let coverPreferences = gameData!.map({ game in
                return CreateMultiTaskPreference(with: game)
            }).joined()
            let coverRequestHeaders = CreateRequestHeader(path: "multiquery", preferences: coverPreferences)
            
            // get game covers
            let coverData = try? await MakeHTTPRequest(with: coverRequestHeaders, as: [CoverQuery].self)
            
            var covers: [CoverObject] = []
            
            coverData!.forEach { cover in
                let filteredGames = gameData!.filter { game in
                    return game.name == cover.name
                }
                
                let nest = CoverObject(id: cover.result.first?.id ?? 0, game: filteredGames.first ?? CreatePlaceHolder().game, url: cover.result.first?.url ?? "")
                
                covers.append(nest)
            }
            
            print(self.isSearching)
            if self.isSearching {
                self.games = covers
            }
        }
    }
}

private func CreateMultiTaskPreference(with game: Game) -> String {
    return """
    query covers "\(game.name)" {
        f url;
        w id = \(String(game.cover ?? 0));
    };
    """
}
