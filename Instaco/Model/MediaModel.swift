//
//  MediaInfoModel.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class MediaInfo: ListDiffable {
    
    let username: String
    let userProfileImage: URL
    let location: String
    let timestamp: Int
    let imageURL: URL
    let likes: Int
    let imageHeight: Int
    let imageWidth: Int
    let beliked: Bool
    let caption: CaptionViewModel
    let id: String
    let userid: Int
    let comment_count: Int
    
    init(username: String, userProfileImage: URL, location: String, timestamp: Int, imageURL: URL, imageHeight: Int, imageWidth: Int, likes: Int, beliked: Bool, caption: CaptionViewModel, id: String, userid: Int, comment_count: Int) {
        self.username = username
        self.userProfileImage = userProfileImage
        self.location = location
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.likes = likes
        self.imageHeight = imageHeight
        self.imageWidth = imageWidth
        self.beliked = beliked
        self.caption = caption
        self.id = id
        self.userid = userid
        self.comment_count = comment_count
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return (username + String(timestamp)) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
    
}
