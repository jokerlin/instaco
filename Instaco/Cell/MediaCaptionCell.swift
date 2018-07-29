//
//  MediaCaptionCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/21/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import ActiveLabel

final class CaptionCell: UICollectionViewCell, ListBindable {
    
    fileprivate static let insets = UIEdgeInsets(top: 4, left: 11, bottom: 4, right: 11)
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
    
    let captionLabel = ActiveLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // label basic config
        captionLabel.backgroundColor = .clear
        captionLabel.textColor = UIColor.darkText
        captionLabel.font = UIFont.systemFont(ofSize: 14)
        captionLabel.textAlignment = .left
        captionLabel.numberOfLines = 0
        captionLabel.sizeToFit()
        
        // ActiveLabel config
        let usernameType = ActiveType.custom(pattern: "\\A[^\\s]+")
        captionLabel.customColor[usernameType] = UIColor.black
        captionLabel.hashtagColor = UIColor.rgb(red: 0, green: 0, blue: 128)
        captionLabel.mentionColor = UIColor.black
        
        // https://github.com/optonaut/ActiveLabel.swift/commit/c1ba467e214bcbc5cec89097a0bffa1f9ef9b895
        captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            switch type {
            case .hashtag:
                atts[NSAttributedStringKey.font] = isSelected ? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
            case .mention:
                atts[NSAttributedStringKey.font] = isSelected ? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
            case usernameType:
                atts[NSAttributedStringKey.font] = UIFont.boldSystemFont(ofSize: 14)
            default: ()
            }
            return atts
        }
        
        captionLabel.enabledTypes = [.mention, .hashtag, usernameType]
        
        // for future features
        captionLabel.handleMentionTap { mentiontag in
            print("Success. You just tapped the \(mentiontag) hashtag")
        }
        captionLabel.handleHashtagTap { hashtag in
            print("Success. You just tapped the \(hashtag) hashtag")
        }
        captionLabel.handleCustomTap(for: usernameType){ usernameType in
            print("Success. You just tapped the \(usernameType) usernametag")
        }
        
        contentView.addSubview(captionLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        captionLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(contentView)
            make.left.equalTo(11)
            make.right.equalTo(contentView).offset(-11)
        }
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? CaptionViewModel else { return }

        captionLabel.text = viewModel.username + " " + viewModel.text
        
    }
    
}
