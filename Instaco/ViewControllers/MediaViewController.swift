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
    private let refreshControl = FixedRefreshControl()
    
    init(media_id id: String) {
        super.init(nibName: nil, bundle: nil)
        media_id = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Media"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshMediaData(_:)), for: .valueChanged)
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
    
    @objc private func refreshMediaData(_ sender: Any) {
        data.removeAll()
        self.mediaJSON2Object()
    }
    
    func mediaJSON2Object() {
        insta.getMediaInfo(id: self.media_id, success: { (JSONResponse) -> Void in
//            print(JSONResponse)
            let mediaResponse = Mapper<MediaResponse>().map(JSONString: JSONResponse.rawString()!)
            if mediaResponse != nil, mediaResponse?.items != nil {
                for item in (mediaResponse?.items)! where item.image_versions2 != nil {
                    if let mediaInfo = media2ObjectHelper(item: item) {
                        self.data.append(mediaInfo)
                        self.adapter.performUpdates(animated: true)
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }, failure: { (JSONResponse) -> Void in
            ifLoginRequire(viewController: self)
            print(JSONResponse)
        })
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
}
