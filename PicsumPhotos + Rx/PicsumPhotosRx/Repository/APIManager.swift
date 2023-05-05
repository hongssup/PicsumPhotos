//
//  APIManager.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/21.
//

import Foundation
import UIKit
import RxSwift

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailure
    case conversionFailure
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "InvalidResponse"
        case .decodingFailure:
            return "DecodingFailure"
        case .conversionFailure:
            return "ConversionFailure"
        }
    }
}

final class APIManager {
    static let shared = APIManager()
    private init() { }
    
    func fetchData(request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statusCode) else { throw APIError.invalidResponse }
        return data
    }
    
    func fetchImageListRx(query: [URLQueryItem]) -> Observable<[Image]> {
        return Observable.create { observer in
            Task {
                do {
                    var components = URLComponents(string: Constants.API.baseURL)
                    components?.queryItems = query

                    guard let url = components?.url else { throw APIError.invalidURL }
                    let request = URLRequest(url: url)
                    
                    let data = try await APIManager.shared.fetchData(request: request)
                    let imageList = try JSONDecoder().decode([Image].self, from: data)
                    
                    observer.onNext(imageList)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchImage(url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        let data = try await APIManager.shared.fetchData(request: request)
        
        guard let image = UIImage(data: data) else { throw APIError.conversionFailure }
        
        return image
    }
}
