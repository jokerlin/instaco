//
//  Response2Object.swift
//  Instaco
//
//  Created by Henry Lin on 8/10/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import SwiftyJSON
import IGListKit

// Media2ObjectHelper
func media2ObjectHelper(item: Media_or_ad) -> MediaInfo? {
    
    var mediainfo: MediaInfo?
    
    if item.type == 3 { // Video
        if item.video_versions != nil {
            mediainfo = MediaInfo(
                username: item.user?.username ?? "",
                userProfileImage: URL(string: item.user?.profile_pic_url ?? "")!,
                location: item.location?.name ?? "",
                timestamp: item.taken_at ?? 0,
                imageURL: URL(string: item.image_versions2![0].url ?? "")!,
                imageHeight: item.image_versions2![0].height ?? 0,
                imageWidth: item.image_versions2![0].width ?? 0,
                likes: item.like_count ?? 0,
                beliked: item.has_liked ?? false,
                caption: CaptionViewModel(username: item.caption?.user?.username ?? "", text: item.caption?.text ?? ""),
                id: item.id ?? "",
                userid: item.user?.pk ?? 0,
                comment_count: item.comment_count ?? 0,
                type: 3,
                videoURL: URL(string: item.video_versions![0].url ?? ""),
                videoHeight: item.video_versions![0].height ?? 0,
                videoWidth: item.video_versions![0].width ?? 0,
                beSaved: item.has_viewer_saved ?? false)
        }
        
    } else if item.type == 2 { // CarouselImage
        if item.carousel_media != nil {
            var urls: [String] = []
            for carousel in item.carousel_media! where carousel.image_versions2 != nil {
                urls.append(carousel.image_versions2![0].url ?? "")
            }
            
            mediainfo = MediaInfo(
                username: item.user?.username ?? "",
                userProfileImage: URL(string: item.user?.profile_pic_url ?? "")!,
                location: item.location?.name ?? "",
                timestamp: item.taken_at ?? 0,
                imageURL: URL(string: item.image_versions2![0].url ?? "")!,
                imageHeight: item.image_versions2![0].height ?? 0,
                imageWidth: item.image_versions2![0].width ?? 0,
                likes: item.like_count ?? 0,
                beliked: item.has_liked ?? false,
                caption: CaptionViewModel(username: item.caption?.user?.username ?? "", text: item.caption?.text ?? ""),
                id: item.id ?? "",
                userid: item.user?.pk ?? 0,
                comment_count: item.comment_count ?? 0,
                type: 2,
                carousel: urls,
                beSaved: item.has_viewer_saved ?? false)
        }
        
    } else { // Image
        mediainfo = MediaInfo(
            username: item.user?.username ?? "",
            userProfileImage: URL(string: item.user?.profile_pic_url ?? "")!,
            location: item.location?.name ?? "",
            timestamp: item.taken_at ?? 0,
            imageURL: URL(string: item.image_versions2![0].url ?? "")!,
            imageHeight: item.image_versions2![0].height ?? 0,
            imageWidth: item.image_versions2![0].width ?? 0,
            likes: item.like_count ?? 0,
            beliked: item.has_liked ?? false,
            caption: CaptionViewModel(username: item.caption?.user?.username ?? "", text: item.caption?.text ?? ""),
            id: item.id ?? "",
            userid: item.user?.pk ?? 0,
            comment_count: item.comment_count ?? 0,
            type: 1,
            beSaved: item.has_viewer_saved ?? false)
    }
    return mediainfo
}

// search2ObjectHelper
func search2ObjectHelper(searchResponse: SearchUserResponse) -> [ListDiffable] {
    var data: [ListDiffable] = []
    
    if searchResponse.users != nil {
        for item in (searchResponse.users)! {
            let searchUserResult = SearchUserModel (pk: item.pk ?? 0,
                                                    profile_image: item.profile_pic_url ?? "",
                                                    search_social_context: item.search_social_context ?? "",
                                                    username: item.username ?? "",
                                                    full_name: item.full_name ?? "")
            data.append(searchUserResult)
        }
    }
    return data
}
