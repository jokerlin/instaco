//
//  MediaCarouselViewModel.swift
//  Instaco
//
//  Created by Henry Lin on 8/5/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class MediaCarouselViewModel: ListDiffable {
    
    let urls: [String]
    
    init(urls: [String]) {
        self.urls = urls
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return "carousel" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? MediaCarouselViewModel else { return false }
        return urls == object.urls
    }
    
}
