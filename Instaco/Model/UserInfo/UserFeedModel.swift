//
//  UserFeedModel.swift
//  Instaco
//
//  Created by Henry Lin on 7/31/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class UserFeed: ListDiffable {
    
    let imageURL: URL
    let imageHeight: Int
    let imageWidth: Int
    let id: String
    
    init(imageURL: URL, imageHeight: Int, imageWidth: Int, id: String) {
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.id = id
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return (imageURL) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}
