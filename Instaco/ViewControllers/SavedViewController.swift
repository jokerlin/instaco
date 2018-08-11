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
    
    @objc private func refreshData(_ sender: Any) {
        savedData.removeAll()
        next_max_id_saved = ""
        next_max_id_saved_previous = ""
        savedMediaJSON2Object()
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
    
    func savedSetup(JSONResponse: JSON) {
        let mediaResponse = Mapper<SavedResponse>().map(JSONString: JSONResponse.rawString()!)
        if mediaResponse?.next_max_id != nil {
            self.next_max_id_saved_previous = self.next_max_id_saved
            self.next_max_id_saved = String((mediaResponse?.next_max_id)!)
        }
        if mediaResponse?.items != nil {
            for item in (mediaResponse?.items!)! {
                if let item = item.media {
                    if let mediaInfo = media2ObjectHelper(item: item) {
                        self.savedData.append(mediaInfo)
                    }
                }
            }
        }
        self.data = self.savedData
        self.adapter.performUpdates(animated: true)
        self.refreshControl.endRefreshing()
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
}
