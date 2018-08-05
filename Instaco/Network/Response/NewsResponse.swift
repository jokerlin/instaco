//
//  NewsResponse.swift
//  Instaco
//
//  Created by Henry Lin on 8/1/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class NewsResponse: Mappable {
    var next_max_id: Int?
    var stories: [Stories]?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        next_max_id <- map["next_max_id"]
        stories <- map["stories"]
    }
    
}

class InboxResponse: Mappable {
    var continuation_token: Int?
    var new_stories: [Stories]?
    var old_stories: [Stories]?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        continuation_token <- map["continuation_token"]
        new_stories <- map["new_stories"]
        old_stories <- map["old_stories"]
    }
    
}

class Stories: Mappable {
    var type: Int?
    var args: Args?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        type <- map["type"]
        args <- map["args"]
    }
}

class Args: Mappable {
    var links: [JSONLinks]?
    var media: [JSONMedia]?
    var profile_id: Int?
    var profile_image: String?
    var text: String?
    var timestamp: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        links <- map["links"]
        media <- map["media"]
        profile_id <- map["profile_id"]
        profile_image <- map["profile_image"]
        text <- map["text"]
        timestamp <- map["timestamp"]
        
    }
}

class JSONMedia: Mappable {
    var id: String?
    var image: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id <- map["id"]
        image <- map["image"]
    }
}

class JSONLinks: Mappable {
    var end: Int?
    var id: Int?
    var start: Int?
    var type: Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        end <- map["end"]
        id <- map["id"]
        start <- map["start"]
        type <- map["type"]
    }
}
