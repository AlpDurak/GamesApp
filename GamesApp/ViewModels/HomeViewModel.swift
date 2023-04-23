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
    
    func fetch() {
        let preferences = "f url,game.name,game.hypes,game.follows,game.storyline,game.url; w url !=n & game.follows !=n & game.storyline !=n & game.url !=n & game.hypes >= 100; l 20;"
        let requestHeader = CreateRequestHeader(path: "covers", preferences: preferences)
        
        let task = URLSession.shared.dataTask(with: requestHeader) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let games = try JSONDecoder().decode([CoverObject].self, from: data)
                DispatchQueue.main.async {
                    self?.games = games
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func search(with searchQuery: String) {
        
        // search for the games
        let searchPreferences = "f name,hypes,follows,cover,url,storyline,summary; w cover !=n & url !=n; search \"\(searchQuery)\";"
        let searchRequestHeader = CreateRequestHeader(path: "games", preferences: searchPreferences)
        let searchTask = URLSession.shared.dataTask(with: searchRequestHeader) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let games = try JSONDecoder().decode([Game].self, from: data)
                DispatchQueue.main.async {
                    if (!games.isEmpty) {
                        // get the covers of the found games
                        let coverPreferences = """
                        \(games.map({ game in
                            return """
                            query covers "\(game.name)" {
                                f url;
                                w id = \(String(game.cover ?? 0));
                            };
                            """
                        }).joined())
                        """
                        
                        let coverRequestHeaders = CreateRequestHeader(path: "multiquery", preferences: coverPreferences)
                        
                        let coverTask = URLSession.shared.dataTask(with: coverRequestHeaders) { data, _, error in
                            guard let data = data, error == nil else { return }
                            
                            do {
                                var covers: [CoverObject] = []
                                
                                let gatheredCovers = try JSONDecoder().decode([CoverQuery].self, from: data)
                                DispatchQueue.main.async {
                                    gatheredCovers.forEach { cover in
                                        let filteredGames = games.filter { game in
                                            game.name == cover.name
                                        }
                                        
                                        let nest = CoverObject(id: cover.result.first?.id ?? 0, game: filteredGames.first ?? CreatePlaceHolder().game, url: cover.result.first?.url ?? "")
                                        
                                        covers.append(nest)
                                    }
                                    self?.games = covers
                                }
                            } catch {
                                print(error)
                            }
                            
                        }
                        coverTask.resume()
                    }
                }
            } catch {
                print(error)
            }
        }
        searchTask.resume()
    }
}
