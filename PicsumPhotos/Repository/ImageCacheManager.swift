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
    
    private var cache: NSCache<NSURL, UIImage> = NSCache()
    private subscript(url: NSURL) -> UIImage? {
        return cache.object(forKey: url)
    }
    
    func imageCache(url: String) async throws -> UIImage {
        guard let url = NSURL(string: url) else {
            throw NSError(domain: "fetch error", code: 1004)
        }

        if let cached = self[url] {
            return cached
        }
        
        let image = try await APIManager.shared.fetchImage(url: url as URL)
        
        cache.setObject(image, forKey: url)
        
        return image
    }
    
    //FileManager의 temporaryDirectory에 이미지 캐싱하고 불러오기
    func getCachedImage(id: String, url: String) async throws -> UIImage {
        guard let url = URL(string: url) else {
            throw NSError(domain: "url error", code: 1004)
        }
        
        let temporaryDirectory = FileManager.default.temporaryDirectory
        var localURL: URL?
        if #available(iOS 16.0, *) {
            localURL = temporaryDirectory.appending(path: id)
        } else {
            localURL = temporaryDirectory.appendingPathComponent(id)
        }
        
        guard let localURL else { throw NSError(domain: "invalid localURL", code: 1004) }
        if let cachedImage = UIImage(contentsOfFile: localURL.path) {
            debugPrint("get cachedImage \(id)")
            return cachedImage
        }
        
        let image = try await APIManager.shared.fetchImage(url: url)
        
        let data = try await cacheImage(image: image, localURL: localURL)

        return UIImage(data: data) ?? image
    }
    
    func cacheImage(image: UIImage, localURL: URL) async throws -> Data {
        debugPrint("cacheImage...")
        guard let data = image.jpegData(compressionQuality: 0.5) else { throw NSError(domain: "invalid localURL", code: 1004) }
        try data.write(to: localURL)
        
        return data
    }
}
