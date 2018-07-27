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

class TimelineViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate{
    
    var data = [ListDiffable]()
    var next_max_id = ""
    var loading = false
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        // solve blank on top of the collectionView
//        self.collectionView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0)
//        self.navigationController?.isNavigationBarHidden = true
        
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
        sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
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
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < -50 ) {
            
            data.removeAll()
            adapter.performUpdates(animated: true, completion: nil)
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    self.loading = false
                    self.timelineJSON2Object(params: insta.generatePostParamsTest())
                    self.adapter.performUpdates(animated: true, completion: nil)
                }
            }
        }
    }
    
    func timelineJSON2Object(params: [String: Any]){
        insta.timelineFeed(params: params, success: {
            (JSONResponse) -> Void in
            let json = JSONResponse
            print("GET JSON RESPONSE")
            
            self.next_max_id = json["next_max_id"].stringValue
            
            let timelineResponse = Mapper<TimelineResponse>().map(JSONString: json.rawString()!)
            if timelineResponse?.feed_items != nil{
                for item in (timelineResponse?.feed_items!)!{
                    
                    var commentArray = Array<CommentViewModel>()
                    var location = ""
                    var caption_username = ""
                    var caption_text = ""
                    
                    if item.media_or_ad?.location != nil{
                        location = (item.media_or_ad?.location?.name)!
                    }
                    if item.media_or_ad?.preview_comments != nil{
                        for comment in (item.media_or_ad?.preview_comments!)!{
                            commentArray.append(CommentViewModel(username: (comment.user?.username!)!, text: comment.text!))
                        }
                    }
                    if item.media_or_ad?.caption != nil{
                        caption_username = (item.media_or_ad?.caption?.user?.username)!
                        caption_text = (item.media_or_ad?.caption?.text)!
                    }
                    
                    if let item = item.media_or_ad{
                        let mediainfo = MediaInfo(
                            username: (item.user?.username)!,
                            userProfileImage: URL(string: (item.user?.profile_pic_url)!)!,
                            location: location,
                            timestamp: item.taken_at!,
                            imageURL: URL(string: item.image_versions2![0].url!)!,
                            imageHeight: item.image_versions2![0].height!,
                            imageWidth: item.image_versions2![0].width!,
                            likes: item.like_count!,
                            comments: commentArray,
                            beliked: item.has_liked!,
                            caption: CaptionViewModel(username: caption_username, text: caption_text),
                            id: item.id!,
                            userid: (item.user?.pk)!
                        )
                        self.data.append(mediainfo)
                    }
                }
            }
            self.adapter.performUpdates(animated: true)
        }, failure: {
            (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
}