//
//  UserInfoHeaderCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/30/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit
import SnapKit

protocol UserInfoHeaderCellDelegate: class {
    func didTapFollow(cell: UserInfoHeaderCell)
}

final class UserInfoHeaderCell: UICollectionViewCell, ListBindable {
    
    weak var delegate: UserInfoHeaderCellDelegate?
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    let biographyLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    let external_urlLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    let media_countLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    let follower_countLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    let following_countLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }()
    
    let followButton: UIButton = {
        let button = UIButton()
        button.setTitle("NA", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.sizeToFit()
        button.backgroundColor = UIColor.white
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(profileImageView)
        contentView.addSubview(fullNameLabel)
        contentView.addSubview(biographyLabel)
        contentView.addSubview(external_urlLabel)
        contentView.addSubview(media_countLabel)
        contentView.addSubview(follower_countLabel)
        contentView.addSubview(following_countLabel)
        followButton.addTarget(self, action: #selector(UserInfoHeaderCell.onFollow), for: .touchUpInside)
        contentView.addSubview(followButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: Autolayout for UI
        profileImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.top.equalTo(20)
            make.left.equalTo(20)
        }
        self.profileImageView.layer.cornerRadius = min(self.profileImageView.frame.height, profileImageView.frame.width) / 2.0
        self.profileImageView.layer.masksToBounds = true
        
        fullNameLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(20)
            make.centerY.equalTo(profileImageView.snp.bottom).offset(10)
        }
        
        biographyLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(20)
             make.centerY.equalTo(profileImageView.snp.bottom).offset(30)
        }
        
        external_urlLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(20)
             make.centerY.equalTo(profileImageView.snp.bottom).offset(50)
        }
        
        media_countLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(10)
        }
        
        follower_countLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(100)
        }
        
        following_countLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(200)
        }
        
        followButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(300)
            
        }
    }
    
    @objc func onFollow() {
        delegate?.didTapFollow(cell: self)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? UserInfo else { return }
        fullNameLabel.text = viewModel.full_name
        biographyLabel.text = viewModel.biography
        external_urlLabel.text = viewModel.external_url
        if viewModel.media_count == 0 || viewModel.media_count == 1 {
            media_countLabel.text = String(viewModel.media_count) + "\n post"
        } else {
            media_countLabel.text = String(viewModel.media_count) + "\n posts"
        }
        
        if viewModel.media_count == 0 || viewModel.media_count == 1 {
            follower_countLabel.text = String(viewModel.follower_count) + "\n follower"
        } else {
            follower_countLabel.text = String(viewModel.follower_count) + "\n followers"
        }
        
        following_countLabel.text = String(viewModel.following_count) + "\n following"
        profileImageView.sd_setImage(with: viewModel.userProfileImage)
        
        if viewModel.username != insta.username {
            if viewModel.friendship == false {
                followButton.backgroundColor = UIColor.blue
                followButton.setTitleColor(UIColor.white, for: .normal)
                followButton.setTitle("follow", for: .normal)
            } else {
                followButton.backgroundColor = UIColor.white
                followButton.setTitleColor(UIColor.black, for: .normal)
                followButton.setTitle("Following", for: .normal)
            }
        } else {
            followButton.isHidden = true
        }
    }
}
