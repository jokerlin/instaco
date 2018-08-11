//
//  MediaVideoViewModel.swift
//  Instaco
//
//  Created by Henry Lin on 8/6/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class VideoViewModel: ListDiffable {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return "video" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ImageViewModel else { return false }
        return url == object.url
    }
    
}
