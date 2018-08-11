//
//  MediaResponse.swift
//  Instaco
//
//  Created by Henry Lin on 8/1/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class ObjectMediaResponse: Mappable {
    var items: [ObjectMedia_or_ad]?
    var next_max_id: Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        items <- map["items"]
        next_max_id <- map["next_max_id"]
    }
}
