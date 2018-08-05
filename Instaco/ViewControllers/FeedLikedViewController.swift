//
//  FeedLikedViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/1/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import ObjectMapper

class FeedLikedViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var media_id: String = ""
    var likedData = [ListDiffable]()
    var savedData = [ListDiffable]()
    var data = [ListDiffable]()
    var loading = false
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let refreshControl = FixedRefreshControl()
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    let segments: [(String, String)] = [
        ("Liked", "liked"),
        ("Saved", "saved")
    ]
    var selectedClass: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let control = UISegmentedControl(items: segments.map { return $0.0 })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(onControl(_:)), for: .valueChanged)
        navigationItem.titleView = control
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshLikedData(_:)), for: .valueChanged)
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
//            print("GET JSON RESPONSE")
//            print(JSONResponse)
            let mediaResponse = Mapper<MediaResponse>().map(JSONString: JSONResponse.rawString()!)

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
                        comment_count: item.comment_count!
                    )
                    self.likedData.append(mediainfo)
                }
            }
            self.data = self.likedData
            self.adapter.performUpdates(animated: true)
            self.refreshControl.endRefreshing()
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    func savedMediaJSON2Object() {
        insta.getFeedSaved(success: { (JSONResponse) -> Void in
//            print(JSONResponse)
            
            let mediaResponse = Mapper<SavedResponse>().map(JSONString: JSONResponse.rawString()!)
            
            if mediaResponse?.items != nil {
                for item in (mediaResponse?.items!)! {
//                    for item in (tmp.media!) {
                    
                        var location = ""
                        var caption_username = ""
                        var caption_text = ""
                        
                    if item.media?.location != nil {
                        location = (item.media?.location?.name)!
                        }
                        
                    if item.media?.caption != nil {
                            caption_username = (item.media?.caption?.user?.username)!
                            caption_text = (item.media?.caption?.text)!
                        }
                        
                        let mediainfo = MediaInfo(
                            username: (item.media?.user?.username)!,
                            userProfileImage: URL(string: (item.media?.user?.profile_pic_url)!)!,
                            location: location,
                            timestamp: (item.media?.taken_at!)!,
                            imageURL: URL(string: (item.media?.image_versions2![0].url!)!)!,
                            imageHeight: (item.media?.image_versions2![0].height!)!,
                            imageWidth: (item.media?.image_versions2![0].width!)!,
                            likes: (item.media?.like_count!)!,
                            beliked: (item.media?.has_liked!)!,
                            caption: CaptionViewModel(username: caption_username, text: caption_text),
                            id: (item.media?.id!)!,
                            userid: (item.media?.user?.pk)!,
                            comment_count: (item.media?.comment_count!)!
                        )
                        self.savedData.append(mediainfo)
                    }
//                }
            }
            self.data = self.savedData
            self.adapter.performUpdates(animated: true)
            self.refreshControl.endRefreshing()
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    @objc private func refreshLikedData(_ sender: Any) {
        if selectedClass == "liked" {
            likedData.removeAll()
            likedMediaJSON2Object()
        } else {
            savedData.removeAll()
            savedMediaJSON2Object()
        }
        
    }
    
    @objc func onControl(_ control: UISegmentedControl) {
        selectedClass = segments[control.selectedSegmentIndex].1
        if selectedClass == "liked" {
            data.removeAll()
            if data.count == 0 {
                likedMediaJSON2Object()
            }
        } else {
            data.removeAll()
            if data.count == 0 {
                savedMediaJSON2Object()
            }
        }
    }
}
