//
//  APITools.swift
//  GamesApp
//
//  Created by Alp on 22.04.2023.
//

import Foundation

func CreateRequestHeader(path URLEnding: String, preferences bodyParams: String) -> URLRequest {
    let infoDictionary: [String: Any] = Bundle.main.infoDictionary!
    let CLIENT_ID: String = infoDictionary["CLIENT_ID"] as! String
    let ACCESS_TOKEN: String = infoDictionary["ACCESS_TOKEN"] as! String
    
    let url = URL(string: "https://api.igdb.com/v4/\(URLEnding)")!
    var requestHeader = URLRequest.init(url: url)
    requestHeader.httpBody = bodyParams.data(using: .utf8, allowLossyConversion: false)
    requestHeader.httpMethod = "POST"
    requestHeader.setValue(CLIENT_ID, forHTTPHeaderField: "Client-ID")
    requestHeader.setValue("Bearer \(ACCESS_TOKEN)", forHTTPHeaderField: "Authorization")
    requestHeader.setValue("application/json", forHTTPHeaderField: "Accept")
    
    return requestHeader
}

func MakeHTTPRequest<T: Codable>(with requestHeader: URLRequest, as type: T.Type) async throws -> T {
    // make HTTP request
    let (data, _) = try await URLSession.shared.data(for: requestHeader)
    
    // decode the data
    let decode = try JSONDecoder().decode(T.self, from: data)
    
    return decode
}
