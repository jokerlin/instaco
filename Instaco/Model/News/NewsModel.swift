//
//  NewsModel.swift
//  Instaco
//
//  Created by Henry Lin on 8/1/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class News: ListDiffable {
    
    var type: Int
    var profile_image: String
    var text: String
    
    init(type: Int, profile_image: String, text: String) {
        self.type = type
        self.profile_image = profile_image
        self.text = text
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return profile_image + text as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? News else { return false }
        return type == object.type
            && profile_image == object.profile_image
            && text == object.text
    }
    
}
