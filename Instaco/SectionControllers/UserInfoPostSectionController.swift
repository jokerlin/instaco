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

    private var object: GridItem?
    
    override init() {
        super.init()
        minimumLineSpacing = 1
        minimumInteritemSpacing = 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        
        return CGSize(width: floor((width - 2 * minimumInteritemSpacing) / 3), height: floor((width - 2 * minimumInteritemSpacing) / 3))
    }
    
    override func numberOfItems() -> Int {
        return object?.itemCount ?? 0
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext!.dequeueReusableCell(of: UserInfoPostCell.self, for: self, at: index) as? UserInfoPostCell else { fatalError("Cell not bindable") }
        cell.imageView.sd_setImage(with: object?.items[index].imageURL)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? GridItem
    }
    
    override func didSelectItem(at index: Int) {
        print("Tap photo " + (object?.items[index].id)!)
    }
}
