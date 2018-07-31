//
//  UserInfoResponse.swift
//  Instaco
//
//  Created by Henry Lin on 7/29/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class UserInfoResponse: Mappable {
    var status: String?
    var user: JSONUserInfo?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        status <- map["status"]
        user <- map["user"]
    }
}

class UserFeedResponse: Mappable {
    var next_max_id: String?
    var items: [Media_or_ad]?
    var num_results: Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        num_results <- map["num_results"]
        items <- map["items"]
        next_max_id <- map["next_max_id"]
    }
}

class JSONUserInfo: Mappable {
    var biography: String?
    var follower_count: Int?
    var following_count: Int?
    var full_name: String?
    var hd_profile_pic_url_info: ImageTimeline?
    var is_private: Int?
    var external_url: String?
    var pk: Int?
    var media_count: Int?
    var username: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        media_count <- map["media_count"]
        biography <- map["biography"]
        follower_count <- map["follower_count"]
        following_count <- map["following_count"]
        full_name <- map["full_name"]
        hd_profile_pic_url_info <- map["hd_profile_pic_url_info"]
        is_private <- map["is_private"]
        external_url <- map["external_url"]
        pk <- map["pk"]
        username <- map["username"]
    }

}
