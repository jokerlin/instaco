//
//  TimelineSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 7/18/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit

final class TimelineSectionController: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource, ActionCellDelegate{
    
    var localLikes: Int? = nil
    var likedFlagChange: Bool = false
    var mediaInfo: MediaInfo?
    
    override init() {
        super.init()
        dataSource = self
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? MediaInfo else { fatalError() }
        mediaInfo = object
        let results: [ListDiffable] = [
            UserViewModel(username: object.username, userProfileImage: object.userProfileImage, location: object.location, timestamp: object.timestamp),
            ImageViewModel(url: object.imageURL),
            ActionViewModel(likes: localLikes ?? object.likes),
            CaptionViewModel(username: object.caption.username, text: object.caption.text),
            ]
        return results + object.comments
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let cellClass: AnyClass
        switch viewModel {
        case is UserViewModel: cellClass = UserCell.self
        case is ImageViewModel: cellClass = ImageCell.self
        case is ActionViewModel: cellClass = ActionCell.self
        case is CaptionViewModel: cellClass = CaptionCell.self
        default: cellClass = CommentCell.self
        }
        guard let cell = collectionContext!.dequeueReusableCell(of: cellClass, for: self, at: index) as? UICollectionViewCell & ListBindable
            else { fatalError("Cell not bindable") }
        
        if let cell = cell as? ActionCell {
            let likes = (mediaInfo?.likes)!.withCommas()
            if (mediaInfo?.likes)! > 1 {
                cell.likesLabel.text = "\(likes)" + " likes"
            }
            else{
                cell.likesLabel.text = "\(likes)" + " like"
            }
            cell.likesLabel.sizeToFit()
            if mediaInfo?.beliked == true{
                let btnImage = UIImage(named: "like_selected")
                cell.likeButton.setImage(btnImage , for: UIControlState.normal)
            }
            else{
                let btnImage = UIImage(named: "like_unselected")
                cell.likeButton.setImage(btnImage , for: UIControlState.normal)
            }
            cell.delegate = self
        }
        return cell
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        let height: CGFloat
        switch viewModel {
        case is UserViewModel: height = 52
        case is ImageViewModel: height = transfromHeight(originalHeight: (mediaInfo?.imageHeight)!, OriginalWidth: (mediaInfo?.imageWidth)!, afterWidth: (collectionContext?.containerSize.width)!)
        case is ActionViewModel: height = 40
        case is CaptionViewModel: height = 30
        case is CommentViewModel: height = 30
        default: height = 0
        }
        return CGSize(width: width, height: height)
    }
    
    func didTapHeart(cell: ActionCell) {
        if mediaInfo?.beliked == true{
            if likedFlagChange == false{
                localLikes = (localLikes ?? mediaInfo?.likes ?? 0) - 1
                likedFlagChange = true
                let btnImage = UIImage(named: "like_unselected")
                cell.likeButton.setImage(btnImage , for: UIControlState.normal)
                insta.likeOp(type: false, media_id: (mediaInfo?.id)!, username: (mediaInfo?.username)!, user_id: (mediaInfo?.userid)!)
            }
            else{
                localLikes = (localLikes ?? mediaInfo?.likes ?? 0) + 1
                likedFlagChange = false
                let btnImage = UIImage(named: "like_selected")
                cell.likeButton.setImage(btnImage , for: UIControlState.normal)
                insta.likeOp(type: true, media_id: (mediaInfo?.id)!, username: (mediaInfo?.username)!, user_id: (mediaInfo?.userid)!)
            }
        }
        else{
            if likedFlagChange == false{
                localLikes = (localLikes ?? mediaInfo?.likes ?? 0) + 1
                likedFlagChange = true
                let btnImage = UIImage(named: "like_selected")
                cell.likeButton.setImage(btnImage , for: UIControlState.normal)
                insta.likeOp(type: true, media_id: (mediaInfo?.id)!, username: (mediaInfo?.username)!, user_id: (mediaInfo?.userid)!)
            }
            else{
                localLikes = (localLikes ?? mediaInfo?.likes ?? 0) - 1
                likedFlagChange = false
                let btnImage = UIImage(named: "like_unselected")
                cell.likeButton.setImage(btnImage , for: UIControlState.normal)
                insta.likeOp(type:false, media_id: (mediaInfo?.id)!, username: (mediaInfo?.username)!, user_id: (mediaInfo?.userid)!)
            }
        }
        update(animated: true)
    }

}

