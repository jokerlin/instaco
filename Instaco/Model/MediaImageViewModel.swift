//
//  MediaImageViewModel.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class ImageViewModel: ListDiffable {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return "image" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ImageViewModel else { return false }
        return url == object.url
    }
    
}
