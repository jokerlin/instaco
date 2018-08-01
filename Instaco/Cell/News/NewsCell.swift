//
//  NewsCell.swift
//  Instaco
//
//  Created by Henry Lin on 8/1/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit

final class NewsCell: UICollectionViewCell, ListBindable {
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        return label
    }()
    
//    let timestampLabel: UILabel = {
//        let label = UILabel()
//        label.backgroundColor = .clear
//        label.numberOfLines = 0
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = UIColor.darkText
//        label.textAlignment = .left
//        label.sizeToFit()
//        return label
//    }()
    
    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(profileImageView)
        contentView.addSubview(textLabel)
//        contentView.addSubview(timestampLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.centerY.equalTo(contentView)
            make.left.equalTo(11)
        }
        self.profileImageView.layer.cornerRadius = min(self.profileImageView.frame.height, profileImageView.frame.width) / 2.0
        self.profileImageView.layer.masksToBounds = true
        
        textLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(9)
        }
        
//        timestampLabel.snp.makeConstraints { (make) -> Void in
//            make.centerY.equalTo(contentView)
//            make.right.equalTo(contentView).offset(-11)
//        }
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? News else { return }
        profileImageView.sd_setImage(with: URL(string: viewModel.profile_image))
        textLabel.text = viewModel.text
//        timestampLabel.text = viewModel.timestamp
    }
}
