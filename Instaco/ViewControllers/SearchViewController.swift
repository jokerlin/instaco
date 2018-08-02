//
//  SearchViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/2/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit
import SwiftyJSON
import ObjectMapper

class SearchViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate, SearchSectionControllerDelegate {
    
    var media_id: String = ""
    var data = [ListDiffable]()
    var loading = false
    var searchString = ""
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    let searchToken: NSNumber = 89757
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.view.addSubview(collectionView)

//        searchUsers(quest: "linheng")
        
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
//        return [searchToken]
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
    
    func searchUsers(quest: String) {
        insta.searchUsers(q: quest, rank_token: insta.uuid, success: { (JSONResponse) -> Void in
//            print(JSONResponse)
            let searchUserResponse = Mapper<SearchUserResponse>().map(JSONString: JSONResponse.rawString()!)
            if searchUserResponse?.users != nil {
                for item in (searchUserResponse?.users)! {

                    let searchUserResult = SearchUserModel (pk: item.pk!, profile_image: item.profile_pic_url!, search_social_context: item.search_social_context, username: item.username!, full_name: item.full_name!)
                    self.data.append(searchUserResult)
                }
            }
            self.adapter.performUpdates(animated: true)
        }, failure: {(JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    // MARK: SearchSectionControllerDelegate
    
    func searchSectionController(_ sectionController: SearchBarSectionController, didChangeText text: String) {
        data.removeAll()
        if text != "" {
            searchUsers(quest: text)
        }
        adapter.performUpdates(animated: true, completion: nil)
    }
}
