//
//  LikesCountViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/10/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import ObjectMapper
import KeychainAccess

class LikesCountViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate, SearchSectionControllerDelegate {
    
    var media_id: String = ""
    var data: [ListDiffable] = []
    var cache: [ListDiffable] = []
    var filterString = ""
    var loading = false
    let searchToken: NSNumber = 89757
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    private let refreshControl = FixedRefreshControl()
    
    init(media_id id: String) {
        super.init(nibName: nil, bundle: nil)
        self.media_id = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Likers"
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshUserInfoData(_:)), for: .valueChanged)
        
        self.view.addSubview(collectionView)
        setup()
        
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        guard filterString != "" else { return [searchToken] + cache.map { $0 as ListDiffable } }
        data=[]
        for item in cache {
            let str = String(item.diffIdentifier() as! Substring)
            if str.contains(filterString) {
                data.append(item)
            }
        }
        return [searchToken] + data as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let obj = object as? NSNumber, obj == searchToken {
            let sectionController = SearchBarSectionController()
            sectionController.delegate = self
            return sectionController
        } else {
            return SearchResultSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    @objc private func refreshUserInfoData(_ sender: Any) {
        data.removeAll()
        setup()
    }
    
    func setup() {
        likersJSON2Object()
        refreshControl.endRefreshing()
    }
    
    func likersJSON2Object() {
        insta.getLikers(media_id: self.media_id, success: { (JSONResponse) in
            print(JSONResponse)
            let likersResponse = Mapper<SearchUserResponse>().map(JSONString: JSONResponse.rawString()!)
            if likersResponse?.users != nil {
                for item in (likersResponse?.users)! {
                    let searchUserResult = SearchUserModel (pk: item.pk!, profile_image: item.profile_pic_url!, search_social_context: item.search_social_context, username: item.username!, full_name: item.full_name!)
                    self.data.append(searchUserResult)
                }
            }
            self.cache = self.data
            self.adapter.performUpdates(animated: true)
        }, failure: { (JSONResponse) in
            ifLoginRequire(viewController: self)
            print(JSONResponse)
        })
    }
    
    func searchSectionController(_ sectionController: SearchBarSectionController, didChangeText text: String) {

        filterString = text
        adapter.performUpdates(animated: true, completion: nil)
    }
}
