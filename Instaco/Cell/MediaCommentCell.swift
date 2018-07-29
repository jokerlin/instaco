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
    
    fileprivate static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    fileprivate static let font = UIFont.systemFont(ofSize: 14)
    
    static func textHeight(_ text: String, width: CGFloat) -> CGFloat {
        if text == "" {
            return 0
        }
        let constrainedSize = CGSize(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [ NSAttributedStringKey.font: font ]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        return ceil(bounds.height) + insets.top + insets.bottom
    }
    
    let commentLabel = ActiveLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // label basic config
        commentLabel.backgroundColor = .clear
        commentLabel.textColor = UIColor.darkText
        commentLabel.font = UIFont.systemFont(ofSize: 14)
        commentLabel.textAlignment = .left
        commentLabel.numberOfLines = 0
        commentLabel.sizeToFit()
        
        // ActiveLabel config
        let usernameType = ActiveType.custom(pattern: "\\A[^\\s]+")
        commentLabel.customColor[usernameType] = UIColor.black
        commentLabel.hashtagColor = UIColor.rgb(red: 0, green: 0, blue: 128)
        commentLabel.mentionColor = UIColor.black
        
        // https://github.com/optonaut/ActiveLabel.swift/commit/c1ba467e214bcbc5cec89097a0bffa1f9ef9b895
        commentLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            switch type {
            case .hashtag:
                atts[NSAttributedStringKey.font] = isSelected ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
            case .mention:
                atts[NSAttributedStringKey.font] = isSelected ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
            case usernameType:
                atts[NSAttributedStringKey.font] = UIFont.boldSystemFont(ofSize: 14)
            default: ()
            }
            return atts
        }
        
        commentLabel.enabledTypes = [.mention, .hashtag, usernameType]
        
        // for future features
        commentLabel.handleMentionTap { mentiontag in
            print("Success. You just tapped the \(mentiontag) hashtag")
        }
        commentLabel.handleHashtagTap { hashtag in
            print("Success. You just tapped the \(hashtag) hashtag")
        }
        
        contentView.addSubview(commentLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        commentLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(contentView)
            make.left.equalTo(11)
            make.right.equalTo(contentView).offset(-11)
        }
    }
    
    // MARK: ListBindable
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? CommentViewModel else { return }
        
        commentLabel.text = viewModel.username + " " + viewModel.text
        
    }
    
}

