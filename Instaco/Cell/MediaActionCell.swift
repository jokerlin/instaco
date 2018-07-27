//
//  MediaActionCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit

protocol ActionCellDelegate: class {
    func didTapHeart(cell: ActionCell)
}

final class ActionCell: UICollectionViewCell, ListBindable {
    
    weak var delegate: ActionCellDelegate? = nil
    
    let likeButton: UIButton = {
        let button = UIButton()
        let btnImage = UIImage(named: "like_unselected")
        button.setImage(btnImage , for: UIControlState.normal)
        button.sizeToFit()
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        let btnImage = UIImage(named: "comment")
        button.setImage(btnImage , for: UIControlState.normal)
        button.sizeToFit()
        return button
    }()
    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        likeButton.addTarget(self, action: #selector(ActionCell.onHeart), for: .touchUpInside)
        contentView.addSubview(likesLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let leftPadding: CGFloat = 8.0
        likeButton.frame = CGRect(x: leftPadding, y: 0, width: likeButton.frame.width, height: bounds.size.height)
        commentButton.frame = CGRect(x: leftPadding + likeButton.frame.maxX, y: 0, width: commentButton.frame.width, height: bounds.size.height)
        likesLabel.frame = CGRect(x: leftPadding + likeButton.frame.maxX + 200, y: 0, width: likesLabel.frame.width, height: bounds.size.height)
    }
    

    @objc func onHeart() {
        delegate?.didTapHeart(cell: self)
    }
    
    func bindViewModel(_ viewModel: Any) {
        
    }

}
