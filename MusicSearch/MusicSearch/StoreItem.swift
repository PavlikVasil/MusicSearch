//
//  StoreItem.swift
//  MusicSearch
//
//  Created by Павел on 9/7/20.
//  Copyright © 2020 Павел. All rights reserved.
//

import Foundation

struct StoreItems: Codable{
    var resultCount: Int
    let results: [StoreItem]?
}

struct StoreItem: Codable, Comparable{
    static func < (lhs: StoreItem, rhs: StoreItem) -> Bool {
        var isSorted = false
        if let first = lhs.collectionName, let second = rhs.collectionName{
            return first < second
        }
        return isSorted
    }
    
    /*static func < (lhs: StoreItem, rhs: StoreItem) -> Bool {
        return lhs.collectionName < rhs.collectionName
    }*/
    
    var artistName: String
    var collectionName: String?
    var collectionId: Int?
    var artworkUrl60: URL
    var artworkUrl100: URL
    var collectionPrice: Double
    var primaryGenreName: String
    
    enum CodingKeys: String, CodingKey{
        case artistName
        case collectionName
        case collectionId
        case artworkUrl60
        case artworkUrl100
        case collectionPrice
        case primaryGenreName
    }
            
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.artistName = try valueContainer.decode(String.self, forKey: CodingKeys.artistName)
        self.collectionName = try? valueContainer.decode(String?.self, forKey: CodingKeys.collectionName)
        self.collectionId = try? valueContainer.decode(Int?.self, forKey: CodingKeys.collectionId)
        self.artworkUrl60 = try valueContainer.decode(URL.self, forKey: CodingKeys.artworkUrl60)
        self.artworkUrl100 = try valueContainer.decode(URL.self, forKey: CodingKeys.artworkUrl100)
        self.collectionPrice = try valueContainer.decode(Double.self, forKey: CodingKeys.collectionPrice)
        self.primaryGenreName = try valueContainer.decode(String.self, forKey: CodingKeys.primaryGenreName)
        }
}


struct Album: Codable{
    var resultCount: Int
    var results: [Tracks]?
}

struct Tracks: Codable{
    var trackName: String?
    var trackNumber: Int?
    
    enum CodingKeys: String, CodingKey{
        case trackName
        case trackNumber
    }
    
    init(from decoder: Decoder) throws {
       let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.trackName = try? valueContainer.decode(String?.self, forKey: CodingKeys.trackName)
        self.trackNumber = try? valueContainer.decode(Int.self, forKey: CodingKeys.trackNumber)
    }
    
}
