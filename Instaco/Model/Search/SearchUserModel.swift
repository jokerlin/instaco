//
//  SearchUserModel.swift
//  Instaco
//
//  Created by Henry Lin on 8/2/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class SearchUserModel: ListDiffable {
    
    var pk: Int
    var profile_image: String
    var username: String
    var full_name: String
    var search_social_context: String?
    
    init(pk: Int, profile_image: String, search_social_context: String?, username: String, full_name: String) {
        self.pk = pk
        self.profile_image = profile_image
        self.search_social_context = search_social_context
        self.username = username
        self.full_name = full_name
        
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
    
}
