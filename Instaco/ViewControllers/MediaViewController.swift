//
//  MediaViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/1/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import ObjectMapper

class MediaViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var media_id: String = ""
    var data = [ListDiffable]()
    var loading = false
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    init(media_id id: String) {
        super.init(nibName: nil, bundle: nil)
        media_id = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Photo"
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.view.addSubview(collectionView)

        mediaJSON2Object()
        
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
    
    func mediaJSON2Object() {
        insta.getMediaInfo(id: self.media_id, success: { (JSONResponse) -> Void in
            print("GET JSON RESPONSE")
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
                    self.data.append(mediainfo)
                    
                }
            }
            self.adapter.performUpdates(animated: true)
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
}