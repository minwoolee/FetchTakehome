//
//  Models.swift
//  FetchTakehome
//
//  Created by Min Woo Lee on 3/16/25.
//

import Foundation

struct Payload: Decodable {
    let recipes: [Recipe]
}

struct Recipe: Decodable {
    let uuid: String
    let cuisine: String
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let sourceUrl: String?
    let youtubeUrl: String?
}
