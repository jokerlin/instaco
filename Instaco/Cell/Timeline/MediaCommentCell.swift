//
//  MediaCommentCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import ActiveLabel

final class CommentCell: UICollectionViewCell, ListBindable {
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(commentLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        commentLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView)
            make.left.equalTo(11)
        }
    }
    
    // MARK: ListBindable
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? CommentViewModel else { return }
        
        if viewModel.comment_count == 0 {
            commentLabel.text = ""
        } else if viewModel.comment_count == 1 {
            commentLabel.text = "View all 1 comment"
        } else {
            commentLabel.text = "View all " + String(viewModel.comment_count) + " comments"
        }
    }
    
}
