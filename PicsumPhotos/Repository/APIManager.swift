//
//  APIManager.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/21.
//

import Foundation
import UIKit

final class APIManager {
    static let shared = APIManager()
    private init() { }
    
    func fetchData(request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statusCode) else { throw NSError(domain: "fetch error", code: 1004) }
        return data
    }
    
    func fetchImageList(query: [URLQueryItem]) async throws -> [Image] {
        var components = URLComponents(string: Constants.API.baseURL)
        components?.queryItems = query

        guard let url = components?.url else { throw NSError(domain: "invalid url", code: 1004) }
        let request = URLRequest(url: url)
        
        let data = try await APIManager.shared.fetchData(request: request)
        let imageList = try JSONDecoder().decode([Image].self, from: data)
        
        return imageList
    }
    
    func fetchImage(url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statusCode) else { throw NSError(domain: "fetch error", code: 1004) }
        guard let image = UIImage(data: data) else { throw NSError(domain: "image coverting error", code: 999)}
        return image
    }
}
