//
//  TimelineViewController.swift
//  Instaco
//
//  Created by Henry Lin on 7/25/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import ObjectMapper

class TimelineViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate, UICollectionViewDelegate {
    
    var data = [ListDiffable]()
    var next_max_id = ""
    var loading = false
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    private let refreshControl = FixedRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Timeline"
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        // solve blank on top of the collectionView
//        self.collectionView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0)
//        self.navigationController?.isNavigationBarHidden = true
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTimelineData(_:)), for: .valueChanged)
        
        self.view.addSubview(collectionView)
        if insta.isLoggedIn {
            timelineJSON2Object(params: insta.generatePostParamsTest())
        }
        
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
        let sectionController = ListStackedSectionController(sectionControllers: [TimelineSectionController()])
        sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
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
                    self.timelineJSON2Object(params: insta.paginationTimelineTest(next_max_id: self.next_max_id))
                    self.adapter.performUpdates(animated: true, completion: nil)
                    
                }
            }
        }
        
    }
    
    func timelineJSON2Object(params: [String: Any]) {
        insta.timelineFeed(params: params, success: { (JSONResponse) -> Void in
//            print("GET JSON RESPONSE")
            
            self.next_max_id = JSONResponse["next_max_id"].stringValue
            
            let timelineResponse = Mapper<TimelineResponse>().map(JSONString: JSONResponse.rawString()!)
            if timelineResponse?.feed_items != nil {
                
                for item in (timelineResponse?.feed_items!)! {
                    var location = ""
                    var caption_username = ""
                    var caption_text = ""
                    
                    if item.media_or_ad?.location != nil {
                        location = (item.media_or_ad?.location?.name)!
                    }
                    
                    if item.media_or_ad?.caption != nil {
                        caption_username = (item.media_or_ad?.caption?.user?.username)!
                        caption_text = (item.media_or_ad?.caption?.text)!
                    }
                    
                    if item.media_or_ad?.type == 3 {
                        if let item = item.media_or_ad {
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
                            self.data.append(mediainfo)
                        }
                        
                    } else if item.media_or_ad?.type == 2 {

                        if let item = item.media_or_ad {
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
                            self.data.append(mediainfo)
                        }
                    } else {
                        if let item = item.media_or_ad {
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
                            self.data.append(mediainfo)
                        }
                    }
                }
            }
            self.adapter.performUpdates(animated: true)
            self.refreshControl.endRefreshing()
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    @objc private func refreshTimelineData(_ sender: Any) {
        data.removeAll()
        next_max_id = ""
        self.timelineJSON2Object(params: insta.generatePostParamsTest())
    }
}
