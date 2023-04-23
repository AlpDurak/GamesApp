//
//  HomeViewModel.swift
//  GamesApp
//
//  Created by Alp on 19.04.2023.
//

import SwiftUI

struct VideoObject: Hashable, Codable {
    let game: Int
    let video_id: String
}

class VideoViewModel: ObservableObject {
    @Published var videos: [VideoObject] = []
    
    func fetch(id gameId: Int) {
        let preferences = "f game,video_id;l 1;w game =\(gameId);"
        let requestHeader = CreateRequestHeader(path: "game_videos", preferences: preferences)
        
        let task = URLSession.shared.dataTask(with: requestHeader) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let videos = try JSONDecoder().decode([VideoObject].self, from: data)
                DispatchQueue.main.async {
                    self?.videos = videos
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
}
