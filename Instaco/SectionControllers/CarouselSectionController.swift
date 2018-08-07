//
//  CarouselSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 8/6/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class CarouselSectionController: ListSectionController {
    private var url: String?
    
    override init() {
        super.init()
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: ImageCell.self, for: self, at: index) as? ImageCell else {
            fatalError()
        }
        cell.imageView.sd_setImage(with: URL(string: url!))
        return cell
    }
    
    override func didUpdate(to object: Any) {
        url = object as? String
    }

}
