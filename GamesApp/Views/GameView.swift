//
//  GameView.swift
//  GamesApp
//
//  Created by Alp on 21.04.2023.
//

import SwiftUI

struct GameView: View {
    var game: CoverObject
    @StateObject var vM = VideoViewModel()
    @State var showVideo = false
    
    var body: some View {
        let ImageURL = URL(string: "https:\(game.url.replacingOccurrences(of: "thumb", with: "1080p"))")!
        
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    
                    if !showVideo {
                        ZStack {
                            AsyncImage(url: ImageURL) { ReturnedImage in
                                ReturnedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 288, height: 162)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 288, height: 162)
                                    .background(Color("SoftBG"))
                            }
                            .border(Color("SoftBG"), width: 4)
                            .cornerRadius(10)
                            
                            if !vM.videos.isEmpty {
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                        .onAppear {
                            vM.fetch(id: game.game.id)
                        }
                        .onTapGesture { showVideo.toggle() }
                    }
                    
                    if showVideo {
                        ZStack {
                            ProgressView()
                                .frame(width: 288, height: 162)
                                .background(Color("SoftBG"))
                            YouTubeView(videoId: "\(vM.videos.first!.video_id)")
                                .frame(width: 288, height: 162)
                        }.cornerRadius(10)
                    }
                    
                    Text(game.game.name)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        InfoLabel(title: "\(game.game.follows ?? 0)", imageName: "person.fill")
                        Text("•").foregroundColor(.secondary)
                        InfoLabel(title: "\(game.game.hypes ?? 0)", imageName: "flame.fill")
                    }
                    
                    Text(game.game.storyline ?? game.game.summary ?? "No Summary or Storyline found for this game")
                        .font(.body)
                        .frame(maxWidth: 600)
                        .padding(20)
                    
                    Spacer()
                    
                    Link(destination: URL(string: game.game.url)!, label: {
                        UniversalButton(label: "Go to Games Website", textColor: .white, backgroundColor: .blue)
                    })
                }.frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
            }
        }
    }
}

struct InfoLabel: View {
    var title: String
    var imageName: String
    
    var body: some View {
        Label(title, systemImage: imageName)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let gameObject = CreatePlaceHolder().coverObject
        
        GameView(game: gameObject)
    }
}
