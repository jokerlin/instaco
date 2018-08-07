//
//  LikedViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/7/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import ObjectMapper

class LikedViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var media_id: String = ""
    var next_max_id_liked_previous = ""
    var next_max_id_liked = ""
    var likedData = [ListDiffable]()
    var data = [ListDiffable]()
    var loading = false
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let refreshControl = FixedRefreshControl()
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Likes"
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.view.addSubview(collectionView)
        
        likedMediaJSON2Object()
        
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return data as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return TimelineSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func likedMediaJSON2Object() {
        insta.getFeedLiked(success: { (JSONResponse) -> Void in
            //            print(JSONResponse)
            self.likedSetup(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    func likedMediaJSON2ObjectPagination() {
        insta.getFeedLiked(max_id: self.next_max_id_liked, success: { (JSONResponse) -> Void in
            //            print(JSONResponse)
            self.likedSetup(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    @objc private func refreshData(_ sender: Any) {
            likedData.removeAll()
            next_max_id_liked = ""
            next_max_id_liked_previous = ""
            likedMediaJSON2Object()
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !loading && distance < 200 {
            
            loading = true
            adapter.performUpdates(animated: true, completion: nil)
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    self.loading = false
                    if self.next_max_id_liked != "" && self.next_max_id_liked != self.next_max_id_liked_previous {
                        self.likedMediaJSON2ObjectPagination()
                    }
                    self.adapter.performUpdates(animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func likedSetup(JSONResponse: JSON) {
        let mediaResponse = Mapper<MediaResponse>().map(JSONString: JSONResponse.rawString()!)
        if mediaResponse?.next_max_id != nil {
            self.next_max_id_liked_previous = self.next_max_id_liked
            self.next_max_id_liked = String((mediaResponse?.next_max_id)!)
        }
        if mediaResponse?.items != nil {
            
            for item in (mediaResponse?.items)! {
                var location = ""
                var caption_username = ""
                var caption_text = ""
                
                if item.location != nil {
                    location = (item.location?.name)!
                }
                
                if item.caption != nil {
                    caption_username = (item.caption?.user?.username)!
                    caption_text = (item.caption?.text)!
                }
                
                if item.type == 3 {
                    
                    let mediainfo = MediaInfo(
                        username: (item.user?.username)!,
                        userProfileImage: URL(string: (item.user?.profile_pic_url)!)!,
                        location: location,
                        timestamp: item.taken_at!,
                        imageURL: URL(string: item.image_versions2![0].url!)!,
                        imageHeight: item.image_versions2![0].height!,
                        imageWidth: item.image_versions2![0].width!,
                        likes: item.like_count!,
                        beliked: item.has_liked!,
                        caption: CaptionViewModel(username: caption_username, text: caption_text),
                        id: item.id!,
                        userid: (item.user?.pk)!,
                        comment_count: item.comment_count!,
                        type: 3,
                        videoURL: URL(string: item.video_versions![0].url!),
                        videoHeight: item.video_versions![0].height,
                        videoWidth: item.video_versions![0].width)
                    self.likedData.append(mediainfo)
                    
                } else if item.type == 2 {
                    
                    var urls: [String] = []
                    for carousel in item.carousel_media! {
                        urls.append(carousel.image_versions2![0].url!)
                    }
                    
                    let mediainfo = MediaInfo(
                        username: (item.user?.username)!,
                        userProfileImage: URL(string: (item.user?.profile_pic_url)!)!,
                        location: location,
                        timestamp: item.taken_at!,
                        imageURL: URL(string: item.image_versions2![0].url!)!,
                        imageHeight: item.image_versions2![0].height!,
                        imageWidth: item.image_versions2![0].width!,
                        likes: item.like_count!,
                        beliked: item.has_liked!,
                        caption: CaptionViewModel(username: caption_username, text: caption_text),
                        id: item.id!,
                        userid: (item.user?.pk)!,
                        comment_count: item.comment_count!,
                        type: 2,
                        carousel: urls)
                    self.likedData.append(mediainfo)
                } else {
                    
                    let mediainfo = MediaInfo(
                        username: (item.user?.username)!,
                        userProfileImage: URL(string: (item.user?.profile_pic_url)!)!,
                        location: location,
                        timestamp: item.taken_at!,
                        imageURL: URL(string: item.image_versions2![0].url!)!,
                        imageHeight: item.image_versions2![0].height!,
                        imageWidth: item.image_versions2![0].width!,
                        likes: item.like_count!,
                        beliked: item.has_liked!,
                        caption: CaptionViewModel(username: caption_username, text: caption_text),
                        id: item.id!,
                        userid: (item.user?.pk)!,
                        comment_count: item.comment_count!)
                    self.likedData.append(mediainfo)
                }
            }
        }
        self.data = self.likedData
        self.adapter.performUpdates(animated: true)
        self.refreshControl.endRefreshing()
    }
}
