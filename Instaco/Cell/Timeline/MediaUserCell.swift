//
//  MediaInfoUserCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit

protocol UserCellDelegate: class {
    func didTapUsername(cell: UserCell)
    func didTapProfileImage(cell: UserCell)
}

final class UserCell: UICollectionViewCell, ListBindable {
    
    var usernameLabelConstraint: Constraint?
    weak var delegate: UserCellDelegate?
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        let tapUsernameLabel = UITapGestureRecognizer(target: self, action: #selector(UserCell.onUsername))
        usernameLabel.addGestureRecognizer(tapUsernameLabel)
        let tapProfileImge = UITapGestureRecognizer(target: self, action: #selector(UserCell.onProfileImage))
        profileImageView.addGestureRecognizer(tapProfileImge)
        contentView.addSubview(locationLabel)
        contentView.addSubview(timestampLabel)
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
        
        if locationLabel.text == "" {
            usernameLabelConstraint?.deactivate()
            usernameLabel.snp.makeConstraints { (make) -> Void in
                usernameLabelConstraint = make.centerY.equalTo(profileImageView).constraint
                make.left.equalTo(profileImageView.snp.right).offset(9)
            }
        } else {
            usernameLabelConstraint?.deactivate()
            usernameLabel.snp.makeConstraints { (make) -> Void in
                usernameLabelConstraint = make.centerY.equalTo(profileImageView).offset(-7).constraint
                make.left.equalTo(profileImageView.snp.right).offset(9)
            }
        }
        
        locationLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView).offset(9)
            make.left.equalTo(profileImageView.snp.right).offset(9)
        }
        
        timestampLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-11)
        }
    }
    
    func responderViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: {$0?.superview}) {
            if let responder = view?.next {
                if responder.isKind(of: UIViewController.self) {
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    
    @objc func onUsername() {
        delegate?.didTapUsername(cell: self)
    }
    
    @objc func onProfileImage() {
        delegate?.didTapProfileImage(cell: self)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? UserViewModel else { return }
        profileImageView.sd_setImage(with: viewModel.userProfileImage)
        usernameLabel.text = viewModel.username
        locationLabel.text = viewModel.location
        timestampLabel.text = viewModel.timestamp
    }
}
