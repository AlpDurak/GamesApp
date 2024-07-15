//
//  HomeViewModel.swift
//  GamesApp
//
//  Created by Alp on 19.04.2023.
//

import SwiftUI

struct VideoQuery: Hashable, Codable {
    let game: Int
    let video_id: String
}

struct WebsiteQuery: Hashable, Codable {
    let url: String
    let trusted: Bool
    let category: Int
    let game: Int
}

struct ResultWebsiteObject: Hashable, Codable {
    let name: String
    let result: [WebsiteQuery]
}

struct ResultVideoObject: Hashable, Codable {
    let name: String
    let result: [VideoQuery]
}

enum WebsiteCategory: Int {
    case IPhone = 10, IPad = 11, Android = 12, Steam = 13, Itch = 15, Epic = 16, GOG = 17
}

class VideoViewModel: ObservableObject {
    @Published var videos: [ResultVideoObject] = []
    @Published var websites: [ResultWebsiteObject] = []
    
    func fetch(id gameId: Int) {
        let preferences = "f game,video_id;l 1;w game =\(gameId);"
        let multiquery = """
        query game_videos "Video" {
            f game,video_id;
            w game =\(gameId);
        };
        query websites "Website" {
            f url,category,trusted,game;
            w trusted = true & game =\(gameId) & category = (10,11,12,13,15,16,17);
        };
        """
        
        
    }
}
