//
//  FixedRefreshControl.swift
//  Instaco
//
//  Created by Henry Lin on 8/2/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit

final class FixedRefreshControl: UIRefreshControl {
    
    override var frame: CGRect {
        get { return super.frame }
        set {
            var newFrame = newValue
            if let superScrollView = superview as? UIScrollView {
                newFrame.origin.x = superScrollView.frame.minX - superScrollView.contentInset.left
            }
            super.frame = newFrame
        }
    }
    
}
