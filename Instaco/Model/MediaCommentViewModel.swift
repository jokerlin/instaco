//
//  MediaInfoCommentViewModel.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class CommentViewModel: ListDiffable {
    
    let comment_count: Int
    
    
    init(comment_count: Int) {
        self.comment_count = comment_count
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return comment_count as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
    
}
