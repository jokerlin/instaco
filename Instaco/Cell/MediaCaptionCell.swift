//
//  MediaCaptionCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/21/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit

final class CaptionCell: UICollectionViewCell, ListBindable {

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(commentLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let leftPadding: CGFloat = 8.0
        usernameLabel.frame = CGRect(x: leftPadding, y: 0, width: usernameLabel.frame.width, height: bounds.size.height)
        commentLabel.frame = CGRect(x: leftPadding + usernameLabel.frame.width + 5, y: 0, width: commentLabel.frame.width, height: bounds.size.height)
    }
    
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? CaptionViewModel else { return }
        usernameLabel.text = viewModel.username
        usernameLabel.sizeToFit()
        commentLabel.text = viewModel.text
        commentLabel.sizeToFit()
    }
    
}
