//
//  MediaActionViewModel.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class ActionViewModel: ListDiffable {
    
    let likes: Int
    let beliked: Bool
    
    init(likes: Int, beliked: Bool) {
        self.likes = likes
        self.beliked = beliked
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return "action" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ActionViewModel else { return false }
        return likes == object.likes
    }
    
}

