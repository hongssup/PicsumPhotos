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
    
    func fetchData(url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statusCode) else { throw NSError(domain: "fetch error", code: 1004) }
        return data
    }
    
    func fetchImageList() async throws -> [Image] {
        guard let url = URL(string: Constants.API.baseURL) else { throw NSError(domain: "invalid url", code: 1004) }
        
        let data = try await fetchData(url: url)
        let imageList = try JSONDecoder().decode([Image].self, from: data)
        
        return imageList
    }
    
    func fetchImage(url: String) async throws -> UIImage {
        guard let url = URL(string: url) else { return UIImage() }
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statusCode) else { throw NSError(domain: "fetch error", code: 1004) }
        guard let image = UIImage(data: data) else { throw NSError(domain: "image coverting error", code: 999)}
        return image
    }
}
