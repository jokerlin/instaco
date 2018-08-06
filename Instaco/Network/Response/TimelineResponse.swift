//
//  TimelineResponse.swift
//  Instaco
//
//  Created by Henry Lin on 7/14/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class TimelineResponse: Mappable {
    var num_results: Int?
    var next_max_id: String?
    var feed_items: [FeedItemsTimeline]?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        num_results <- map["num_results"]
        feed_items <- map["feed_items"]
    }
    
}

class FeedItemsTimeline: Mappable {
    var media_or_ad: Media_or_ad?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        media_or_ad <- map["media_or_ad"]

    }
}

class Carousel_media: Mappable {
    var image_versions2: [ImageTimeline]?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        image_versions2 <- map["image_versions2.candidates"]
        
    }
}

class Media_or_ad: Mappable {
    var image_versions2: [ImageTimeline]?
    var like_count: Int?
    var user: User?
    var type: Int?
    var has_liked: Bool?
    var location: Location?
    var preview_comments: [PreviewComments]?
    var taken_at: Int?
    var caption: Caption?
    var id: String?
    var comment_count: Int?
    var carousel_media: [Carousel_media]?
    var video_versions: [ImageTimeline]?
    
    required init?(map: Map) {
        if map.JSON["video_versions"] != nil {
            type = 3
        } else if map.JSON["image_versions2"] != nil {
            type = 1
        } else if map.JSON["carousel_media"] != nil {
            type = 2
        }
        if map.JSON["ad_header_style"] != nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        if type == 1 {
            image_versions2 <- map["image_versions2.candidates"]
            like_count <- map["like_count"]
            user <- map["user"]
            has_liked <- map["has_liked"]
            location <- map["location"]
            taken_at <- map["taken_at"]
            preview_comments <- map["preview_comments"]
            caption <- map["caption"]
            id <- map["id"]
            comment_count <- map["comment_count"]
        } else if type == 2 {
            image_versions2 <- map["carousel_media.0.image_versions2.candidates"]
            carousel_media <- map["carousel_media"]
            like_count <- map["like_count"]
            user <- map["user"]
            has_liked <- map["has_liked"]
            location <- map["location"]
            taken_at <- map["taken_at"]
            preview_comments <- map["preview_comments"]
            caption <- map["caption"]
            id <- map["id"]
            comment_count <- map["comment_count"]
        } else {
            image_versions2 <- map["image_versions2.candidates"]
            video_versions <- map["video_versions"]
            like_count <- map["like_count"]
            user <- map["user"]
            has_liked <- map["has_liked"]
            location <- map["location"]
            taken_at <- map["taken_at"]
            preview_comments <- map["preview_comments"]
            caption <- map["caption"]
            id <- map["id"]
            comment_count <- map["comment_count"]
        }
    }
}

class Caption: Mappable {
    var user: User?
    var text: String?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        user <- map["user"]
        text <- map["text"]
    }
}

class User: Mappable {
    var username: String?
    var profile_pic_url: String?
    var pk: Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        username <- map["username"]
        profile_pic_url <- map["profile_pic_url"]
        pk <- map["pk"]
    }
}

class ImageTimeline: Mappable {
    var height: Int?
    var url: String?
    var width: Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        height <- map["height"]
        url <- map["url"]
        width <- map["width"]
    }
}

class Location: Mappable {
    var name: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        name <- map["name"]
    }
}

class PreviewComments: Mappable {
    var user: User?
    var text: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        user <- map["user"]
        text <- map["text"]
    }
}
