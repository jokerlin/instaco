//
//  UserInfoPostCell.swift
//  Instaco
//
//  Created by Henry Lin on 7/31/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit

final class UserInfoPostCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }()
    
    let videoFlag: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        view.image = UIImage(named: "video")
        view.isHidden = true
        return view
    }()
    
    let carouselFlag: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        view.image = UIImage(named: "carousel")
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(videoFlag)
        contentView.addSubview(carouselFlag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        imageView.frame = bounds
        
        videoFlag.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView).offset(3)
            make.right.equalTo(contentView).offset(-3)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        
        carouselFlag.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView).offset(3)
            make.right.equalTo(contentView).offset(-3)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
    }
    
}
