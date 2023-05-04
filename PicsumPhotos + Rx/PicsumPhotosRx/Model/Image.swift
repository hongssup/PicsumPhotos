//
//  Image.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/21.
//

import Foundation

struct Image: Codable {
    var id: String
    var author: String
    var width: Int
    var height: Int
    var url: String
    var downloadUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadUrl = "download_url"
    }
}


