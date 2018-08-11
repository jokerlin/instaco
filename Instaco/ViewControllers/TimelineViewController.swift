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
    
//    var data: [Any] = []
    var data = [ListDiffable]()
    var next_max_id = ""
    var loading = false
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    private let refreshControl = FixedRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Timeline"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTimelineData(_:)), for: .valueChanged)
        self.view.addSubview(collectionView)
        // solve blank on top of the collectionView
//        self.collectionView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0)
//        self.navigationController?.isNavigationBarHidden = true

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
//        return data as! [ListDiffable]
        return data as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
//        switch object {
//        case is String: return TipSectionController()
//        default:
//            let sectionController = ListStackedSectionController(sectionControllers: [TimelineSectionController()])
//            sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
//            return sectionController
//        }
//        return TimelineSectionController()
        let sectionController = ListStackedSectionController(sectionControllers: [TimelineSectionController()])
        sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    @objc private func refreshTimelineData(_ sender: Any) {
        data.removeAll()
        next_max_id = ""
        self.timelineJSON2Object(params: insta.generatePostParamsTest())
    }
    
    func timelineJSON2Object(params: [String: Any]) {
        insta.timelineFeed(params: params, success: { (JSONResponse) -> Void in
//            print(JSONResponse)
            self.next_max_id = JSONResponse["next_max_id"].stringValue
            
            let timelineResponse = Mapper<ObjectTimelineResponse>().map(JSONString: JSONResponse.rawString()!)
            if timelineResponse?.feed_items != nil {
                
                for item in (timelineResponse?.feed_items!)! {
                    if let item = item.media_or_ad {
                        if let mediaInfo = media2ObjectHelper(item: item) {
                            self.data.append(mediaInfo)
                        }
                    }
                }
            }
//            if self.data.count == 0 {
//                self.data.append("No Timeline Feed for you now.")
//            }
            self.adapter.performUpdates(animated: true)
            self.refreshControl.endRefreshing()
        }, failure: { JSONResponse in
            print(JSONResponse)
            ifLoginRequire(viewController: self)
        })
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
}
