//
//  SearchUserResponse.swift
//  Instaco
//
//  Created by Henry Lin on 8/2/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class SearchUserResponse: Mappable {
    var users: [JSONUsers]?
    var next_max_id: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        users <- map["users"]
        next_max_id <- map["next_max_id"]
    }
}

class JSONUsers: Mappable {
    var username: String?
    var profile_pic_url: String?
    var mutual_followers_count: Int?
    var full_name: String?
    var friendship_status: Friendship_status?
    var search_social_context: String?
    var pk: Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        username <- map["username"]
        profile_pic_url <- map["profile_pic_url"]
        mutual_followers_count <- map["mutual_followers_count"]
        full_name <- map["full_name"]
        friendship_status <- map["friendship_status"]
        search_social_context <- map["search_social_context"]
        pk <- map["pk"]
    }
}

class Friendship_status: Mappable {
    var incoming_request: Bool?
    var outgoing_request: Bool?
    var following: Bool?
    var is_private: Bool?
    var is_bestie: Bool?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        incoming_request <- map["incoming_request"]
        outgoing_request <- map["outgoing_request"]
        following <- map["following"]
        is_private <- map["is_private"]
        is_bestie <- map["is_bestie"]
    }
}

class SuggestedSearchResponse: Mappable {
    var suggested: [JSONSuggestUsers]?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        suggested <- map["suggested"]
        
    }
}

class JSONSuggestUsers: Mappable {
    var user: JSONUsers?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        user <- map["user"]
        
    }
}
