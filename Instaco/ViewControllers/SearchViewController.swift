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
    var searched: [Any] = []
    var quest: String = ""
    var paginationFlag = true
    let searchToken: NSNumber = 89757
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.view.addSubview(collectionView)
        searchSuggest()
        
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
        
        hideKeyboardWhenTappedAround()
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
                    self.searched.append(item.pk!)
                    self.data.append(searchUserResult)
                }
            }
            self.adapter.performUpdates(animated: true)
        }, failure: {(JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    func searchSuggestPagination(q: String) {
        let exlist = ("users", searched as Any)
        let json = JSON(dictionaryLiteral: exlist)
        insta.searchUsers(exclude_list: json, q: q, rank_token: insta.uuid, success: { (JSONResponse) in
            //            print(JSONResponse)
            let searchUserResponse = Mapper<SearchUserResponse>().map(JSONString: JSONResponse.rawString()!)
            if searchUserResponse?.users != nil {
                for item in (searchUserResponse?.users)! {
                    
                    let searchUserResult = SearchUserModel (pk: item.pk!, profile_image: item.profile_pic_url!, search_social_context: item.search_social_context, username: item.username!, full_name: item.full_name!)
                    self.searched.append(item.pk!)
                    self.data.append(searchUserResult)
                }
            }
            self.adapter.performUpdates(animated: true)
        }, failure: { (JSONResponse) in
            print(JSONResponse)
            self.paginationFlag = false
        })
    }
    
    func searchSuggest() {
        insta.searchSuggested(success: { (JSONResponse) -> Void in
//            print(JSONResponse)
            let suggestedSearchResponse = Mapper<SuggestedSearchResponse>().map(JSONString: JSONResponse.rawString()!)
            if suggestedSearchResponse?.suggested != nil {
                for item in (suggestedSearchResponse?.suggested)! where item.user != nil {
                    let searchUserResult = SearchUserModel (pk: (item.user?.pk!)!, profile_image: (item.user?.profile_pic_url!)!, search_social_context: item.user?.search_social_context, username: (item.user?.username!)!, full_name: (item.user?.full_name!)!)
                    self.data.append(searchUserResult)
                }
            }
            self.adapter.performUpdates(animated: true)
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    // MARK: SearchSectionControllerDelegate
    
    func searchSectionController(_ sectionController: SearchBarSectionController, didChangeText text: String) {
        data.removeAll()
        searched.removeAll()
        paginationFlag = true
        if text != "" {
            quest = text
            searchUsers(quest: text)
        } else {
           searchSuggest()
        }
        adapter.performUpdates(animated: true, completion: nil)
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
                    if self.paginationFlag {
                        self.searchSuggestPagination(q: self.quest)
                    }
                    self.adapter.performUpdates(animated: true, completion: nil)
                }
            }
        }
        
    }
}
