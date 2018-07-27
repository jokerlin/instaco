//
//  MediaInfoUserCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit

final class UserCell: UICollectionViewCell, ListBindable {
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.darkText
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17)
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
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(timestampLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        
        let profileImageViewWidth: CGFloat = 25.0
        let profileImageViewTopSpace: CGFloat = (bounds.height - profileImageViewWidth) / 2.0
        let profileImageViewLeftSpace: CGFloat = 8.0
        self.profileImageView.frame = CGRect(x: profileImageViewLeftSpace, y: profileImageViewTopSpace, width: profileImageViewWidth, height: profileImageViewWidth)
        self.profileImageView.layer.cornerRadius = min(self.profileImageView.frame.height, profileImageView.frame.width) / 2.0
        self.profileImageView.layer.masksToBounds = true
        
        self.usernameLabel.frame = CGRect(x:self.profileImageView.frame.maxX + 8.0,
                                          y:self.profileImageView.frame.minY,
                                          width: bounds.width - self.profileImageView.frame.maxX - 8.0*2,
                                          height:self.profileImageView.frame.height)
        
        self.locationLabel.frame = CGRect(x:self.profileImageView.frame.maxX + 200.0,
                                          y:self.profileImageView.frame.minY,
                                          width: bounds.width - self.profileImageView.frame.maxX - 8.0*2,
                                          height:self.profileImageView.frame.height)
        
        self.timestampLabel.frame = CGRect(x:self.profileImageView.frame.maxX + 100.0,
                                          y:self.profileImageView.frame.minY,
                                          width: bounds.width - self.profileImageView.frame.maxX - 8.0*2,
                                          height:self.profileImageView.frame.height)
    }
    
    func bindViewModel(_ viewModel: Any) {
    }
}
