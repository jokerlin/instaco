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
    var externalURL = ""
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    let biographyLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    let external_urlLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        label.textAlignment = .left
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let media_countLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let follower_countLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let following_countLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }()
    
    let fixPostLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.textAlignment = .left
        label.text = "posts"
        label.sizeToFit()
        return label
    }()
    let fixFollowingLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.textAlignment = .left
        label.text = "following"
        label.sizeToFit()
        return label
    }()
    let fixFollowerLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.textAlignment = .left
        label.text = "followers"
        label.sizeToFit()
        return label
    }()
    
    let followButton: UIButton = {
        let button = UIButton()
        button.setTitle("NA", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(profileImageView)
        contentView.addSubview(fullNameLabel)
        contentView.addSubview(biographyLabel)
        contentView.addSubview(external_urlLabel)
        let tapURL = UITapGestureRecognizer(target: self, action: #selector(tapExternalURL))
        external_urlLabel.addGestureRecognizer(tapURL)
        contentView.addSubview(media_countLabel)
        contentView.addSubview(follower_countLabel)
        contentView.addSubview(following_countLabel)
        followButton.addTarget(self, action: #selector(UserInfoHeaderCell.onFollow), for: .touchUpInside)
        contentView.addSubview(followButton)
        contentView.addSubview(fixPostLabel)
        contentView.addSubview(fixFollowingLabel)
        contentView.addSubview(fixFollowerLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.top.equalTo(11)
            make.left.equalTo(11)
        }
        self.profileImageView.layer.cornerRadius = min(self.profileImageView.frame.height, profileImageView.frame.width) / 2.0
        self.profileImageView.layer.masksToBounds = true
        
        fullNameLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(11)
            make.centerY.equalTo(profileImageView.snp.bottom).offset(20)
        }
        
        biographyLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(11)
            make.top.equalTo(fullNameLabel.snp.bottom).offset(5)
            make.right.equalTo(-11)
        }
        
        external_urlLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(11)
            make.top.equalTo(biographyLabel.snp.bottom).offset(5)
        }
        
        media_countLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(follower_countLabel.snp.top).offset(-35)
            make.left.equalTo(profileImageView.snp.right).offset(30)
        }
        
        follower_countLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(30)
        }
        
        following_countLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(follower_countLabel.snp.top).offset(35)
            make.left.equalTo(profileImageView.snp.right).offset(30)
        }
        
        fixPostLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(media_countLabel)
            make.left.equalTo(media_countLabel.snp.right).offset(10)
        }
        
        fixFollowerLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(follower_countLabel)
            make.left.equalTo(follower_countLabel.snp.right).offset(10)
        }
        
        fixFollowingLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(following_countLabel)
            make.left.equalTo(following_countLabel.snp.right).offset(10)
        }
        
        followButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(follower_countLabel)
            make.right.equalTo(contentView).offset(-11)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }
    
    @objc func onFollow() {
        delegate?.didTapFollow(cell: self)
    }
    
    @objc func tapExternalURL() {
        if let link = URL(string: externalURL) {
            UIApplication.shared.open(link)
        }
    }
    
    fileprivate static let insets = UIEdgeInsets(top: 8, left: 11, bottom: 8, right: 11)
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
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? UserInfo else { return }
        fullNameLabel.text = viewModel.full_name
        biographyLabel.text = viewModel.biography
        external_urlLabel.text = viewModel.external_url
        media_countLabel.text = Double(viewModel.media_count).kmFormatted
        follower_countLabel.text = Double(viewModel.follower_count).kmFormatted
        following_countLabel.text = Double(viewModel.following_count).kmFormatted
        profileImageView.sd_setImage(with: viewModel.userProfileImage)
        
        if viewModel.media_count == 0 || viewModel.media_count == 1 {
            fixPostLabel.text = "post"
        }
        if viewModel.follower_count == 0 || viewModel.follower_count == 1 {
            fixFollowerLabel.text = "follower"
        }

        if viewModel.username != insta.username {
            if viewModel.friendship == false {
                followButton.setTitle("Follow", for: .normal)
            } else {
                followButton.setTitle("Following", for: .normal)
            }
        } else {
            followButton.isHidden = true
        }
        
        externalURL = viewModel.external_url
    }
}
