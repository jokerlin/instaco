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
    func didTapRibbon(cell: ActionCell)
}

final class ActionCell: UICollectionViewCell, ListBindable {
    
    weak var delegate: ActionCellDelegate? 
    
    let likeButton: UIButton = {
        let button = UIButton()
        let btnImage = UIImage(named: "like_unselected")
        button.setImage(btnImage, for: UIControlState.normal)
        button.sizeToFit()
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        let btnImage = UIImage(named: "comment")
        button.setImage(btnImage, for: UIControlState.normal)
        button.sizeToFit()
        return button
    }()
    
    let ribbonButton: UIButton = {
        let button = UIButton()
        let btnImage = UIImage(named: "ibook")
        button.setImage(btnImage, for: UIControlState.normal)
        button.sizeToFit()
        return button
    }()
    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        likeButton.addTarget(self, action: #selector(ActionCell.onHeart), for: .touchUpInside)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        ribbonButton.addTarget(self, action: #selector(ActionCell.onRibbon), for: .touchUpInside)
        contentView.addSubview(ribbonButton)
        contentView.addSubview(likesLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        likeButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView)
            make.left.equalTo(11)
        }
        
        commentButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView)
            make.left.equalTo(likeButton).offset(40)
        }
        
        ribbonButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView)
            make.left.equalTo(commentButton).offset(40)
        }
        
        likesLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-11)
        }

    }

    @objc func onHeart() {
        delegate?.didTapHeart(cell: self)
    }
    
    @objc func onRibbon() {
        delegate?.didTapRibbon(cell: self)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ActionViewModel else { return }
        let likes = viewModel.likes.withCommas()
        if viewModel.likes > 1 {
            likesLabel.text = "\(likes)" + " likes"
        } else {
            likesLabel.text = "\(likes)" + " like"
        }
        likesLabel.sizeToFit()
    }

}
