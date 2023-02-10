//
//  VideoPlayer.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import Foundation
 
struct VideoPlayer:Decodable {
    var image:String
    var name:String
    var section:String
    var urlPlayer:String
    
    init(image: String, name: String, section: String, urlPlayer: String) {
        self.image = image
        self.name = name
        self.section = section
        self.urlPlayer = urlPlayer
    }
    
    enum CodingKeys: CodingKey {
        case image
        case name
        
        case section
        case urlPlayer
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.image, forKey: .image)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.section, forKey: .section)
        try container.encode(self.urlPlayer, forKey: .urlPlayer)
    }
}
