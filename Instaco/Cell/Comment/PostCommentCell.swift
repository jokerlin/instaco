//
//  PostCommentCell.swift
//  Instaco
//
//  Created by Henry Lin on 8/11/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit
import SnapKit
import ActiveLabel
import ObjectMapper

protocol PostCommentCellDelegate: class {
    func didTapUsername(cell: PostCommentCell)
}

final class PostCommentCell: UICollectionViewCell, ListBindable {
    
    weak var delegate: PostCommentCellDelegate?
    
    let textLabel = ActiveLabel()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.textAlignment = .left

        label.sizeToFit()
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
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
    
//    let likesLabel: UILabel = {
//        let label = UILabel()
//        label.backgroundColor = .clear
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = UIColor.darkText
//        label.textAlignment = .left
//        label.isUserInteractionEnabled = true
//        label.sizeToFit()
//        return label
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // label basic config
        textLabel.backgroundColor = .clear
        textLabel.textColor = UIColor.darkText
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        
        // ActiveLabel config
        textLabel.hashtagColor = UIColor.rgb(red: 0, green: 0, blue: 128)
        textLabel.mentionColor = UIColor.rgb(red: 0, green: 0, blue: 128)
        
        textLabel.enabledTypes = [.mention, .hashtag]
        
        textLabel.handleMentionTap { mentiontag in
            print("Success. You just tapped the \(mentiontag) hashtag")
            insta.searchUsers(q: mentiontag, success: { (JSONResponse) in
                //                print(JSONResponse)
                let searchUserResponse = Mapper<ObjectSearchUserResponse>().map(JSONString: JSONResponse.rawString()!)
                if searchUserResponse?.users != nil {
                    let item = (searchUserResponse?.users![0])!
                    let searchUserResult = SearchUserModel (pk: item.pk!, profile_image: item.profile_pic_url!, search_social_context: item.search_social_context, username: item.username!, full_name: item.full_name!)
                    if searchUserResult.username == mentiontag {
                        let current_vc = self.responderViewController()
                        let userInfoViewController = UserInfoViewController(username_id: String(item.pk!))
                        current_vc?.navigationController?.pushViewController(userInfoViewController, animated: true)
                    }
                }
            }, failure: { (JSONResponse) in
                print(JSONResponse)
            })
        }
        textLabel.handleHashtagTap { hashtag in
            print("Success. You just tapped the \(hashtag) hashtag")
        }
        
        contentView.addSubview(textLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timestampLabel)
//        contentView.addSubview(likesLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(profileImageView.snp.bottom).offset(5)
            make.left.equalTo(usernameLabel.snp.left)
            make.right.equalTo(contentView).offset(-11)
        }
        
        profileImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.top.equalTo(contentView).offset(5)
            make.left.equalTo(11)
        }
        self.profileImageView.layer.cornerRadius = min(self.profileImageView.frame.height, profileImageView.frame.width) / 2.0
        self.profileImageView.layer.masksToBounds = true
        
        timestampLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView)
            make.right.equalTo(contentView).offset(-11)
        }
        
        usernameLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(9)
        }
        
//        likesLabel.snp.makeConstraints { (make) -> Void in
//            make.centerY.equalTo(timestampLabel)
//            make.left.equalTo(timestampLabel).offset(20)
//        }
    }
    
    func onUsername() {
        delegate?.didTapUsername(cell: self)
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
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? Comment else { return }
        usernameLabel.text = viewModel.username
        textLabel.text = viewModel.text
        profileImageView.sd_setImage(with: URL(string: viewModel.profile_image))
        let unixTimestamp = Double(viewModel.timestamp)
        let timestamp = Date(timeIntervalSince1970: unixTimestamp).timeAgoDisplay()
        timestampLabel.text = timestamp
        
    }
}
