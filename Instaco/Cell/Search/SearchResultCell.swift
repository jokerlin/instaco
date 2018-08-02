//
//  SearchResultCell.swift
//  Instaco
//
//  Created by Henry Lin on 8/2/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit

final class SearchResultCell: UICollectionViewCell, ListBindable {
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.textAlignment = .left
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        return label
    }()
    
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
        contentView.addSubview(usernameLabel)
        contentView.addSubview(textLabel)
        
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
        
        usernameLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView).offset(-7)
            make.left.equalTo(profileImageView.snp.right).offset(9)
        }
        
        textLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView).offset(9)
            make.left.equalTo(profileImageView.snp.right).offset(9)
        }
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? SearchUserModel else { return }
        profileImageView.sd_setImage(with: URL(string: viewModel.profile_image))
        usernameLabel.text = viewModel.username
        if let text = viewModel.search_social_context {
            textLabel.text = text
        } else {
            textLabel.text = viewModel.full_name
        }
        
    }
}
