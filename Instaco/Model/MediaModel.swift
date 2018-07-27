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
    let comments: [CommentViewModel]
    let imageHeight: Int
    let imageWidth: Int
    let beliked: Bool
    let caption: CaptionViewModel
    let id: String
    let userid: Int
    
    init(username: String, userProfileImage: URL, location: String, timestamp: Int, imageURL: URL, imageHeight: Int, imageWidth: Int, likes: Int, comments: [CommentViewModel], beliked: Bool, caption: CaptionViewModel, id: String, userid: Int) {
        self.username = username
        self.userProfileImage = userProfileImage
        self.location = location
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.likes = likes
        self.comments = comments
        self.imageHeight = imageHeight
        self.imageWidth = imageWidth
        self.beliked = beliked
        self.caption = caption
        self.id = id
        self.userid = userid
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return (username + String(timestamp)) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
    
}
