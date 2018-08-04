//
//  SavedResponse.swift
//  Instaco
//
//  Created by Henry Lin on 8/4/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class SavedResponse: Mappable {
    var items: [SavedMedia]?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        items <- map["items"]
        
    }
}

class SavedMedia: Mappable {
    var media: Media_or_ad?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        media <- map["media"]
        
    }
}
