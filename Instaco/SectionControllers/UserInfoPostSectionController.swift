//
//  UserInfoPostSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 7/30/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit
import SDWebImage

class UserInfoPostSectionController: ListSectionController {

    private var object: UserFeed?
    
    override func sizeForItem(at index: Int) -> CGSize {
        // TODO: Resize Cell
        return CGSize(width: 137, height: 137)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext!.dequeueReusableCell(of: UserInfoPostCell.self, for: self, at: index) as? UserInfoPostCell else { fatalError("Cell not bindable") }
        cell.imageView.sd_setImage(with: object?.imageURL)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? UserFeed
    }
    
    override func didSelectItem(at index: Int) {
        print("Tap photo " + (object?.imageURL.absoluteString)!)
    }
}
