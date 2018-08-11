//
//  UserInfoModel.swift
//  Instaco
//
//  Created by Henry Lin on 7/30/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class UserInfo: ListDiffable {
    
    var biography: String
    var follower_count: Int
    var following_count: Int
    var full_name: String
    var userProfileImage: URL
    var is_private: Bool
    var external_url: String
    var pk: Int
    var media_count: Int
    var username: String
    var profileImageimageHeight: Int
    var profileImageimageWidth: Int
    var friendship: Bool
    
    init(username: String, userProfileImage: URL, full_name: String, biography: String, profileImageimageHeight: Int, profileImageimageWidth: Int, follower_count: Int, following_count: Int, is_private: Bool, external_url: String, pk: Int, media_count: Int, friendship: Bool) {
        self.username = username
        self.userProfileImage = userProfileImage
        self.full_name = full_name
        self.biography = biography
        self.follower_count = follower_count
        self.following_count = following_count
        self.is_private = is_private
        self.profileImageimageHeight = profileImageimageHeight
        self.profileImageimageWidth = profileImageimageWidth
        self.external_url = external_url
        self.pk = pk
        self.media_count = media_count
        self.friendship = friendship
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return (username + String(pk)) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? UserInfo else { return false }
        return username == object.username
            && pk == object.pk
    }
    
}

final class GridItem: NSObject {
    
    let itemCount: Int
    var items: [UserFeed] = []
    
    init(items: [UserFeed]) {
        self.items = items
        self.itemCount = items.count
        
        super.init()
        
    }
}

extension GridItem: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
}
