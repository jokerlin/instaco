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

final class TimelineSectionController: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource, ListAdapterDataSource, ActionCellDelegate, UserCellDelegate, ImageCellDelegate, CaptionCellDelegate, CommentCellDelegate, ListDisplayDelegate {
    
    var localLikes: Int?
    var likedFlagChange: Bool = false
    var savedFlagChange: Bool = false
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
    
    // MARK: ListBindingSectionController
    
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
                       CarouselViewModel(urls: object.carousel!),
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
        case is CarouselViewModel: cellClass = MediaCarouselCell.self
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
        if let cell = cell as? ImageCell {
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
            if mediaInfo?.beSaved == true {
                let btnImage = UIImage(named: "ibook_selected")
                cell.ribbonButton.setImage(btnImage, for: UIControlState.normal)
            } else {
                let btnImage = UIImage(named: "ibook")
                cell.ribbonButton.setImage(btnImage, for: UIControlState.normal)
            }
            cell.delegate = self
        }
        if let cell = cell as? CommentCell {
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
        case is CarouselViewModel: height = transfromHeight(originalHeight: (mediaInfo?.imageHeight)!, OriginalWidth: (mediaInfo?.imageWidth)!, afterWidth: (collectionContext?.containerSize.width)!)
        case is VideoViewModel: height = transfromHeight(originalHeight: (mediaInfo?.videoHeight)!, OriginalWidth: (mediaInfo?.videoWidth)!, afterWidth: (collectionContext?.containerSize.width)!)
        case is ActionViewModel: height = 40
        case is CaptionViewModel:
            height = CaptionCell.textHeight(mediaInfo?.caption.text ?? "", width: width)
        case is CommentViewModel:
            if mediaInfo?.comment_count == 0 {
                height = 0
            } else {
                height = 15
            }
            
        default: height = 0
        }
        return CGSize(width: width, height: height)
    }
    
    // MARK: ActionCellDelegate
    
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
    
    func didTapRibbon(cell: ActionCell) {
        if mediaInfo?.beSaved == true {
            if savedFlagChange == false {
                savedFlagChange = true
                let btnImage = UIImage(named: "ibook")
                cell.ribbonButton.setImage(btnImage, for: UIControlState.normal)
                insta.saveOp(type: false, media_id: (mediaInfo?.id)!)
            } else {
                savedFlagChange = false
                let btnImage = UIImage(named: "ibook_selected")
                cell.ribbonButton.setImage(btnImage, for: UIControlState.normal)
                insta.saveOp(type: true, media_id: (mediaInfo?.id)!)
            }
        } else {
            if savedFlagChange == false {
                savedFlagChange = true
                let btnImage = UIImage(named: "ibook_selected")
                cell.ribbonButton.setImage(btnImage, for: UIControlState.normal)
                insta.saveOp(type: true, media_id: (mediaInfo?.id)!)
            } else {
                savedFlagChange = false
                let btnImage = UIImage(named: "ibook")
                cell.ribbonButton.setImage(btnImage, for: UIControlState.normal)
                insta.saveOp(type: false, media_id: (mediaInfo?.id)!)   
            }
        }
        update(animated: true)
    }
    
    func didTapLikesCount(cell: ActionCell) {
        
        let likesCountViewController = LikesCountViewController(media_id: (mediaInfo?.id)!)
        viewController?.navigationController?.pushViewController(likesCountViewController, animated: true)
    }
    
    // MARK: UserCellDelegate
    
    func didTapUsername(cell: UserCell) {
        let userInfoViewController = UserInfoViewController(username_id: String((mediaInfo?.userid)!))
        viewController?.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
    func didTapProfileImage(cell: UserCell) {
        let userInfoViewController = UserInfoViewController(username_id: String((mediaInfo?.userid)!))
        viewController?.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
    // MARK: CaptionCellDelegate
    
    func didTapUsername(cell: CaptionCell) {
        let userInfoViewController = UserInfoViewController(username_id: String((mediaInfo?.userid)!))
        viewController?.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
    // MARK: ImageCellDelegate
    
    func didLongPressImage(cell: ImageCell) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Save to Camera Roll", style: .default, handler: { (_) in
        
            let selector = #selector(self.onCompleteCapture(image:error:contextInfo:))
            UIImageWriteToSavedPhotosAlbum(cell.imageView.image!, self, selector, nil)

        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func onCompleteCapture(image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            print("SAVE SUCCESS")
            let alertController = UIAlertController(title: "Successfully saved", message: nil, preferredStyle: .alert)
            viewController?.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.viewController?.dismiss(animated: false, completion: nil)
            }
        } else {
            print("SAVE FAILED")
            let alertController = UIAlertController(title: "Failed to save", message: "Please enable camera roll access in Settings", preferredStyle: .alert)
            viewController?.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.viewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // CommentCellDelegate
    func didTapViewComments(cell: CommentCell) {
        let commentViewController = CommentViewController(media_id: mediaInfo?.id ?? "")
        viewController?.navigationController?.pushViewController(commentViewController, animated: true)
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
