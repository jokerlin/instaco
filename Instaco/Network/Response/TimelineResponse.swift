//
//  TimelineResponse.swift
//  Instaco
//
//  Created by Henry Lin on 7/14/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import ObjectMapper

class ObjectTimelineResponse: Mappable {
    var num_results: Int?
    var next_max_id: String?
    var feed_items: [ObjectFeedItemsTimeline]?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        num_results <- map["num_results"]
        feed_items <- map["feed_items"]
    }
    
}

class ObjectFeedItemsTimeline: Mappable {
    var media_or_ad: ObjectMedia_or_ad?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        media_or_ad <- map["media_or_ad"]

    }
}

class ObjectCarousel_media: Mappable {
    var image_versions2: [ObjectImageTimeline]?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        image_versions2 <- map["image_versions2.candidates"]
        
    }
}

class ObjectMedia_or_ad: Mappable {
    var image_versions2: [ObjectImageTimeline]?
    var like_count: Int?
    var user: ObjectUser?
    var type: Int?
    var has_liked: Bool?
    var location: ObjectLocation?
    var preview_comments: [ObjectPreviewComments]?
    var taken_at: Int?
    var caption: ObjectCaption?
    var id: String?
    var comment_count: Int?
    var carousel_media: [ObjectCarousel_media]?
    var video_versions: [ObjectImageTimeline]?
    var has_viewer_saved: Bool?
    
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
            has_viewer_saved <- map["has_viewer_saved"]
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
            has_viewer_saved <- map["has_viewer_saved"]
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
            has_viewer_saved <- map["has_viewer_saved"]
        }
    }
}

class ObjectCaption: Mappable {
    var user: ObjectUser?
    var text: String?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        user <- map["user"]
        text <- map["text"]
    }
}

class ObjectUser: Mappable {
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

class ObjectImageTimeline: Mappable {
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

class ObjectLocation: Mappable {
    var name: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        name <- map["name"]
    }
}

class ObjectPreviewComments: Mappable {
    var user: ObjectUser?
    var text: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        user <- map["user"]
        text <- map["text"]
    }
}
