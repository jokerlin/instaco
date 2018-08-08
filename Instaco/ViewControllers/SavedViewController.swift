//
//  SavedViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/7/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import ObjectMapper

class SavedViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var media_id: String = ""
    var next_max_id_saved_previous = ""
    var next_max_id_saved = ""
    var savedData = [ListDiffable]()
    var data = [ListDiffable]()
    var loading = false
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let refreshControl = FixedRefreshControl()
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Saved"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.view.addSubview(collectionView)
        
        savedMediaJSON2Object()
        
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
    
    func savedMediaJSON2Object() {
        insta.getFeedSaved(success: { (JSONResponse) -> Void in
//                        print(JSONResponse)
            self.savedSetup(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) -> Void in
            ifLoginRequire(viewController: self)
            print(JSONResponse)
        })
    }
    
    func savedMediaJSON2ObjectPagination() {
        insta.getFeedSaved(max_id: self.next_max_id_saved, success: { (JSONResponse) -> Void in
            //            print(JSONResponse)
            self.savedSetup(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    @objc private func refreshData(_ sender: Any) {
            savedData.removeAll()
            next_max_id_saved = ""
            next_max_id_saved_previous = ""
            savedMediaJSON2Object()
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
                    if self.next_max_id_saved != "" {
                        if self.next_max_id_saved != "" && self.next_max_id_saved != self.next_max_id_saved_previous {
                            self.savedMediaJSON2ObjectPagination()
                        }
                    }
                    self.adapter.performUpdates(animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func savedSetup(JSONResponse: JSON) {
        let mediaResponse = Mapper<SavedResponse>().map(JSONString: JSONResponse.rawString()!)
        if mediaResponse?.next_max_id != nil {
            self.next_max_id_saved_previous = self.next_max_id_saved
            self.next_max_id_saved = String((mediaResponse?.next_max_id)!)
        }
        if mediaResponse?.items != nil {
            for item in (mediaResponse?.items!)! {
                
                var location = ""
                var caption_username = ""
                var caption_text = ""
                var has_viewer_saved = false
                if item.media?.location != nil {
                    location = (item.media?.location?.name)!
                }
                
                if item.media?.caption != nil {
                    caption_username = (item.media?.caption?.user?.username)!
                    caption_text = (item.media?.caption?.text)!
                }
                
                if item.media?.has_viewer_saved != nil {
                    has_viewer_saved = (item.media?.has_viewer_saved!)!
                }
                
                if item.media?.type == 3 {
                    
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
                        comment_count: (item.media?.comment_count!)!,
                        type: 3,
                        videoURL: URL(string: (item.media?.video_versions![0].url!)!),
                        videoHeight: item.media?.video_versions![0].height,
                        videoWidth: item.media?.video_versions![0].width,
                        beSaved: has_viewer_saved)
                    self.savedData.append(mediainfo)
                    
                } else if item.media?.type == 2 {
                    
                    var urls: [String] = []
                    for carousel in (item.media?.carousel_media!)! {
                        urls.append(carousel.image_versions2![0].url!)
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
                        comment_count: (item.media?.comment_count!)!,
                        type: 2,
                        carousel: urls,
                        beSaved: has_viewer_saved)
                    self.savedData.append(mediainfo)
                } else {
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
                        comment_count: (item.media?.comment_count!)!,
                        beSaved: has_viewer_saved)
                    self.savedData.append(mediainfo)
                }
            }
        }
        self.data = self.savedData
        self.adapter.performUpdates(animated: true)
        self.refreshControl.endRefreshing()
    }
}
