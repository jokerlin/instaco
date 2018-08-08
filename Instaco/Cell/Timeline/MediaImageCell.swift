//
//  MediaImageCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import SDWebImage
import IGListKit

protocol ImageCellDelegate: class {
    func didLongPressImage(cell: ImageCell)
}

final class ImageCell: UICollectionViewCell, ListBindable {
    
    weak var delegate: ImageCellDelegate?
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ImageCell.onImage))
        longPressRecognizer.minimumPressDuration = 0.5
        imageView.addGestureRecognizer(longPressRecognizer)
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        imageView.frame = bounds
    }
    
    @objc func onImage() {
        delegate?.didLongPressImage(cell: self)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ImageViewModel else { return }
        imageView.sd_setImage(with: viewModel.url)
    }
    
}
