//
//  NewsModel.swift
//  VRGTestApp
//
//  Created by shizo663 on 23.03.2021.
//

import Foundation


struct NewsModel: Codable {
    let results: [News]?
}

struct News: Codable {
    let uri: String?
    let url: String?
    let id: Int?
    let source: String?
    let published: String?
    let media: [Media]
    let title: String?
    let type: String?
    let abstract: String?
    
    enum CodingKeys: String, CodingKey {
        case published = "published_date"
        case uri
        case id
        case source
        case url
        case media
        case title
        case type
        case abstract
        
    }
}

struct Media: Codable {
    let media: [MediaData]
    
    enum CodingKeys: String, CodingKey {
        case media = "media-metadata"
    }
}

struct MediaData: Codable {
    let url: String?
    
}
