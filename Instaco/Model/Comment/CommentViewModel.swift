//
//  CommentViewModel.swift
//  Instaco
//
//  Created by Henry Lin on 8/11/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class Comment: ListDiffable {
    
    var profile_image: String
    var username: String
    var user_id: Int
    var text: String
    var timestamp: Int
    var comment_like_count: Int
    var has_liked_comment: Bool
    
    init(username: String, profile_image: String, user_id: Int, text: String, comment_like_count: Int, timestamp: Int, has_liked_comment: Bool) {
        self.username = username
        self.profile_image = profile_image
        self.user_id  = user_id
        self.text = text
        self.comment_like_count = comment_like_count
        self.timestamp = timestamp
        self.has_liked_comment = has_liked_comment
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return String(user_id + timestamp) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Comment else { return false }
        return user_id == object.user_id
            && text == object.text
    }
    
}
