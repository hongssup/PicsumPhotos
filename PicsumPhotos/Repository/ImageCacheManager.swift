//
//  ImageCacheManager.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/22.
//

import Foundation
import UIKit

actor ImageCacheManager {
    static let shared = ImageCacheManager()
    private init() { }
    
    private var cache: [URL: UIImage] = [:]
    
    func imageCache(url: String) async throws -> UIImage {
        guard let url = URL(string: url) else {
            throw NSError(domain: "fetch error", code: 1004)
        }

        if let cached = cache[url] {
            return cached
        }
        
        let image = try await APIManager.shared.fetchImage(url: url)
        
        cache[url] = image
        
        return cache[url] ?? image
    }
}
