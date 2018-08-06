//
//  MediaCarouselCell.swift
//  Instaco
//
//  Created by Henry Lin on 8/5/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import SDWebImage
import IGListKit

final class MediaCarouselCell: UICollectionViewCell, ListBindable {
    var data: [String] = []
    
    lazy var carousel: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(carousel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        carousel.frame = contentView.frame
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? MediaCarouselViewModel else { return }
        self.data = viewModel.urls
    }
}
