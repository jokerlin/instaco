//
//  FriendshipResponse.swift
//  Instaco
//
//  Created by Henry Lin on 8/5/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class ObjectFriendshipResponse: Mappable {
    var is_blocking_reel: Bool?
    var is_muting_reel: Bool?
    var is_private: Bool?
    var muting: Bool?
    var followed_by: Bool?
    var following: Bool?
    var outgoing_request: Bool?
    var blocking: Bool?
    var incoming_request: Bool?
    var is_bestie: Bool?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        is_blocking_reel <- map["is_blocking_reel"]
        is_muting_reel <- map["is_muting_reel"]
        is_private <- map["is_private"]
        muting <- map["muting"]
        followed_by <- map["followed_by"]
        following <- map["following"]
        outgoing_request <- map["outgoing_request"]
        blocking <- map["blocking"]
        incoming_request <- map["incoming_request"]
        is_bestie <- map["is_bestie"]
    }
}
