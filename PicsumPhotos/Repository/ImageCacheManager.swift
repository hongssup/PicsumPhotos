//
//  ImageCacheManager.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/22.
//

import Foundation
import UIKit

enum CacheError: Error {
    case invalidURL
    case invalidLocalURL
    case invalidData
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Cache Error - Invalid URL"
        case .invalidLocalURL:
            return "Cache Error - InvalidLocalURL"
        case .invalidData:
            return "Cache Error - InvalidData"
        }
    }
}

actor ImageCacheManager {
    static let shared = ImageCacheManager()
    private init() { }
    
    private var cache: NSCache<NSURL, UIImage> = NSCache()
    private subscript(url: NSURL) -> UIImage? {
        return cache.object(forKey: url)
    }
    
    // Memory Cache
    func imageCache(url: String) async throws -> UIImage {
        guard let url = NSURL(string: url) else { throw CacheError.invalidURL }

        if let cached = self[url] {
            return cached
        }
        
        let image = try await APIManager.shared.fetchImage(url: url as URL)
        
        cache.setObject(image, forKey: url)
        
        return image
    }
    
    // Disk Cache
    func getCachedImage(id: String, url: String) async throws -> UIImage {
        guard let url = URL(string: url) else { throw CacheError.invalidURL }
        // 파일 저장할 임시 디렉토리 생성
        let temporaryDirectory = FileManager.default.temporaryDirectory
        var localURL: URL?
        if #available(iOS 16.0, *) {
            localURL = temporaryDirectory.appending(path: id)
        } else {
            localURL = temporaryDirectory.appendingPathComponent(id)
        }
        // 해당 디렉토리에 파일이 존재하면 캐시된 이미지를 불러오기
        guard let localURL else { throw CacheError.invalidLocalURL }
        if let cachedImage = UIImage(contentsOfFile: localURL.path) {
            #if DEBUG
            debugPrint("get cachedImage \(id)")
            #endif
            return cachedImage
        }
        // 이미지 다운로드 후 캐싱 처리
        let image = try await APIManager.shared.fetchImage(url: url)
        
        let data = try await cacheImage(image: image, localURL: localURL)

        return UIImage(data: data) ?? image
    }
    
    func cacheImage(image: UIImage, localURL: URL) async throws -> Data {
        #if DEBUG
        debugPrint("cacheImage...")
        #endif
        guard let data = image.jpegData(compressionQuality: 0.5) else { throw CacheError.invalidData }
        try data.write(to: localURL)
        
        return data
    }
}
