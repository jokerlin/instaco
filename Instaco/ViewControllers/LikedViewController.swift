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
//    var data: [Any] = []
//    var likedData: [Any] = []
    var loading = false
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let refreshControl = FixedRefreshControl()
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Likes"
        self.navigationController?.navigationBar.tintColor = UIColor.black
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
    
    @objc private func refreshData(_ sender: Any) {
        likedData.removeAll()
        next_max_id_liked = ""
        next_max_id_liked_previous = ""
        likedMediaJSON2Object()
    }
    
    func likedMediaJSON2Object() {
        insta.getFeedLiked(success: { (JSONResponse) -> Void in
            //            print(JSONResponse)
            self.likedSetup(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) -> Void in
            ifLoginRequire(viewController: self)
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
    
    func likedSetup(JSONResponse: JSON) {
        let mediaResponse = Mapper<ObjectMediaResponse>().map(JSONString: JSONResponse.rawString()!)
        if mediaResponse?.next_max_id != nil {
            self.next_max_id_liked_previous = self.next_max_id_liked
            self.next_max_id_liked = String((mediaResponse?.next_max_id)!)
        }
        if mediaResponse?.items != nil {
            for item in (mediaResponse?.items)! where item.image_versions2 != nil {
                if let mediaInfo = media2ObjectHelper(item: item) {
                    self.likedData.append(mediaInfo)
                }
            }
        }
        
//        if self.likedData.count == 0 {
//            self.likedData.append("No liked posts.")
//        }
        self.data = self.likedData
        self.adapter.performUpdates(animated: true)
        self.refreshControl.endRefreshing()
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
//        return data as! [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
//        return TimelineSectionController()
//        switch object {
//        case is String: return TipSectionController()
//        default:
//            let sectionController = ListStackedSectionController(sectionControllers: [TimelineSectionController()])
//            sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
//            return sectionController
//        }
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
                    if self.next_max_id_liked != "" && self.next_max_id_liked != self.next_max_id_liked_previous {
                        self.likedMediaJSON2ObjectPagination()
                    }
                    self.adapter.performUpdates(animated: true, completion: nil)
                    
                }
            }
        }
    }
}
