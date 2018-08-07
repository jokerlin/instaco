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
import Player

final class TimelineSectionController: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource, ListAdapterDataSource, ActionCellDelegate, UserCellDelegate, CaptionCellDelegate, ListDisplayDelegate {

    var localLikes: Int?
    var likedFlagChange: Bool = false
    var mediaInfo: MediaInfo?
    var carousel_urls: [String] = []
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        
        return adapter
    }()
    
    override init() {
        super.init()
        dataSource = self
        displayDelegate = self
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? MediaInfo else { fatalError() }
        mediaInfo = object
        var results: [ListDiffable] = []
        if mediaInfo?.type == 1 {
            results = [UserViewModel(username: object.username, userProfileImage: object.userProfileImage, location: object.location, timestamp: object.timestamp),
                       ImageViewModel(url: object.imageURL),
                       ActionViewModel(likes: localLikes ?? object.likes),
                       CaptionViewModel(username: object.caption.username, text: object.caption.text),
                       CommentViewModel(comment_count: object.comment_count)]
        } else if mediaInfo?.type == 2 {
            carousel_urls = object.carousel!
            results = [UserViewModel(username: object.username, userProfileImage: object.userProfileImage, location: object.location, timestamp: object.timestamp),
                       MediaCarouselViewModel(urls: object.carousel!),
                       ActionViewModel(likes: localLikes ?? object.likes),
                       CaptionViewModel(username: object.caption.username, text: object.caption.text),
                       CommentViewModel(comment_count: object.comment_count)]
        } else {
            results = [UserViewModel(username: object.username, userProfileImage: object.userProfileImage, location: object.location, timestamp: object.timestamp),
                       VideoViewModel(url: object.videoURL!),
                       ActionViewModel(likes: localLikes ?? object.likes),
                       CaptionViewModel(username: object.caption.username, text: object.caption.text),
                       CommentViewModel(comment_count: object.comment_count)]
        }
        return results 
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        
        let cellClass: AnyClass
        
        switch viewModel {
        case is UserViewModel: cellClass = UserCell.self
        case is ImageViewModel: cellClass = ImageCell.self
        case is MediaCarouselViewModel: cellClass = MediaCarouselCell.self
        case is VideoViewModel: cellClass = VideoCell.self
        case is ActionViewModel: cellClass = ActionCell.self
        case is CaptionViewModel: cellClass = CaptionCell.self
        default: cellClass = CommentCell.self
        }
        
        guard let cell = collectionContext!.dequeueReusableCell(of: cellClass, for: self, at: index) as? UICollectionViewCell & ListBindable
            else { fatalError("Cell not bindable") }
        if let cell = cell as? UserCell {
            cell.delegate = self
        }
        if let cell = cell as? MediaCarouselCell {
            adapter.collectionView = cell.carousel
            adapter.scrollViewDelegate = cell
            cell.pageControl.numberOfPages = (mediaInfo?.carousel?.count)!
        }
        if let cell = cell as? VideoCell {
            cell.player.view.frame = cell.bounds
            cell.player.url = mediaInfo?.videoURL
        }
        if let cell = cell as? CaptionCell {
            cell.delegate = self
        }
        if let cell = cell as? ActionCell {
            if mediaInfo?.beliked == true {
                let btnImage = UIImage(named: "like_selected")
                cell.likeButton.setImage(btnImage, for: UIControlState.normal)
            } else {
                let btnImage = UIImage(named: "like_unselected")
                cell.likeButton.setImage(btnImage, for: UIControlState.normal)
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
        case is MediaCarouselViewModel: height = transfromHeight(originalHeight: (mediaInfo?.imageHeight)!, OriginalWidth: (mediaInfo?.imageWidth)!, afterWidth: (collectionContext?.containerSize.width)!)
        case is VideoViewModel: height = transfromHeight(originalHeight: (mediaInfo?.videoHeight)!, OriginalWidth: (mediaInfo?.videoWidth)!, afterWidth: (collectionContext?.containerSize.width)!)
        case is ActionViewModel: height = 40
        case is CaptionViewModel:
            height = CaptionCell.textHeight(mediaInfo?.caption.text ?? "", width: width)
        case is CommentViewModel:
            if mediaInfo?.comment_count == 0 {
                height = 0
            } else {
                height = 20
            }
            
        default: height = 0
        }
        return CGSize(width: width, height: height)
    }
    
    func didTapHeart(cell: ActionCell) {
        if mediaInfo?.beliked == true {
            if likedFlagChange == false {
                localLikes = (localLikes ?? mediaInfo?.likes ?? 0) - 1
                likedFlagChange = true
                let btnImage = UIImage(named: "like_unselected")
                cell.likeButton.setImage(btnImage, for: UIControlState.normal)
                insta.likeOp(type: false, media_id: (mediaInfo?.id)!, username: (mediaInfo?.username)!, user_id: (mediaInfo?.userid)!)
            } else {
                localLikes = (localLikes ?? mediaInfo?.likes ?? 0) + 1
                likedFlagChange = false
                let btnImage = UIImage(named: "like_selected")
                cell.likeButton.setImage(btnImage, for: UIControlState.normal)
                insta.likeOp(type: true, media_id: (mediaInfo?.id)!, username: (mediaInfo?.username)!, user_id: (mediaInfo?.userid)!)
            }
        } else {
            if likedFlagChange == false {
                localLikes = (localLikes ?? mediaInfo?.likes ?? 0) + 1
                likedFlagChange = true
                let btnImage = UIImage(named: "like_selected")
                cell.likeButton.setImage(btnImage, for: UIControlState.normal)
                insta.likeOp(type: true, media_id: (mediaInfo?.id)!, username: (mediaInfo?.username)!, user_id: (mediaInfo?.userid)!)
            } else {
                localLikes = (localLikes ?? mediaInfo?.likes ?? 0) - 1
                likedFlagChange = false
                let btnImage = UIImage(named: "like_unselected")
                cell.likeButton.setImage(btnImage, for: UIControlState.normal)
                insta.likeOp(type: false, media_id: (mediaInfo?.id)!, username: (mediaInfo?.username)!, user_id: (mediaInfo?.userid)!)
            }
        }
        update(animated: true)
    }
    
    func didTapUsername(cell: UserCell) {
        let current_vc = cell.responderViewController()
        let userInfoViewController = UserInfoViewController(username_id: String((mediaInfo?.userid)!))
        current_vc?.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
    func didTapProfileImage(cell: UserCell) {
        let current_vc = cell.responderViewController()
        let userInfoViewController = UserInfoViewController(username_id: String((mediaInfo?.userid)!))
        current_vc?.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
    func didTapUsername(cell: CaptionCell) {
        let current_vc = cell.responderViewController()
        let userInfoViewController = UserInfoViewController(username_id: String((mediaInfo?.userid)!))
        current_vc?.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
    // MARK: ListAdapterDataSource of CarouselCell
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return carousel_urls as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return CarouselSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: DisplayDelegate
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let cell = cell as? VideoCell {
            cell.player.muted = true
            cell.player.playFromBeginning()
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let cell = cell as? VideoCell {
            cell.player.stop()
        }
    }
}
