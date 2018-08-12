//
//  TipSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 8/11/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit
import UIKit

final class TipSectionController: ListSectionController {
    
    private var object: String?
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: UserTipCell.self, for: self, at: index) as? UserTipCell else {
            fatalError()
        }
        cell.text = object
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.object = String(describing: object)
    }
    
}
