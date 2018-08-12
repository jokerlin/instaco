//
//  CommentResponse.swift
//  Instaco
//
//  Created by Henry Lin on 8/11/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class ObjectCommentResponse: Mappable {
    var comments: [ObjectComments]?
    var next_min_id: String?
    var comment_count: Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        comment_count <- map["comment_count"]
        next_min_id <- map["next_min_id"]
        comments <- map["comments"]
    }
}

class ObjectComments: Mappable {
    var comment_like_count: Int?
    var text: String?
    var user: ObjectUser?
    var has_liked_comment: Bool?
    var created_at_utc: Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        comment_like_count <- map["comment_like_count"]
        text <- map["text"]
        user <- map["user"]
        has_liked_comment <- map["has_liked_comment"]
        created_at_utc <- map["created_at_utc"]
    }
}
