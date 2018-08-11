//
//  FriendshipViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/7/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import ObjectMapper
import KeychainAccess

class FriendshipViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate, SearchSectionControllerDelegate {
    
    var username_id: Int = 0
    var type = ""
    var data: [ListDiffable] = []
    var next_max_id = ""
    var loading = false
    let searchToken: NSNumber = 89757
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    private let refreshControl = FixedRefreshControl()
    
    init(username_id id: Int, type: String) {
        super.init(nibName: nil, bundle: nil)
        username_id = id
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = self.type + "s"
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshUserInfoData(_:)), for: .valueChanged)
        self.view.addSubview(collectionView)
        hideKeyboardWhenTappedAround()
        
        setup()
        
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc private func refreshUserInfoData(_ sender: Any) {
        data.removeAll()
        self.next_max_id = ""
        setup()
    }
    
    func setup() {
        if self.type == "Follower" {
            followerJSON2Object()
        } else {
            followingJSON2Object()
        }
        refreshControl.endRefreshing()
    }
    
    func followerJSON2Object() {
        insta.getUserFriendshipFollower(user_id: username_id, success: { (JSONResponse) in
//            print(JSONResponse)
            self.followerJSON2ObjectHelper(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) in
            ifLoginRequire(viewController: self)
            print(JSONResponse)
        })
    }
    
    func followerJSON2ObjectPagination() {
        insta.getUserFriendshipFollower(user_id: username_id, next_max_id: self.next_max_id, success: { (JSONResponse) in
//            print(JSONResponse)
            self.followerJSON2ObjectHelper(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) in
            print(JSONResponse)
        })
    }
    
    func followerJSON2ObjectHelper(JSONResponse: JSON) {
        let followerResponse = Mapper<SearchUserResponse>().map(JSONString: JSONResponse.rawString()!)
        if followerResponse?.next_max_id != nil {
            self.next_max_id = (followerResponse?.next_max_id!)!
        }
        if followerResponse != nil {
            self.data += search2ObjectHelper(searchResponse: followerResponse!)
        }
        self.adapter.performUpdates(animated: true)
    }
    
    func followingJSON2Object() {
        insta.getUserFriendshipFollowing(user_id: username_id, success: { (JSONResponse) in
//            print(JSONResponse)
            self.followingJSON2ObjectHelper(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) in
            ifLoginRequire(viewController: self)
            print(JSONResponse)
        })
    }
    
    func followingJSON2ObjectPagination() {
        insta.getUserFriendshipFollowing(user_id: username_id, next_max_id: self.next_max_id, success: { (JSONResponse) in
//            print(JSONResponse)
            self.followingJSON2ObjectHelper(JSONResponse: JSONResponse)
        }, failure: { (JSONResponse) in
            print(JSONResponse)
        })
    }
    
    func followingJSON2ObjectHelper(JSONResponse: JSON) {
        let followingResponse = Mapper<SearchUserResponse>().map(JSONString: JSONResponse.rawString()!)
        if followingResponse?.next_max_id != nil {
            self.next_max_id = (followingResponse?.next_max_id!)!
        }
        if followingResponse != nil {
            self.data += search2ObjectHelper(searchResponse: followingResponse!)
        }
        self.adapter.performUpdates(animated: true)
    }
    
    func searchUsers(quest: String) {
        if self.type == "Follower" {
            insta.searchUserFriendshipFollower(query: quest, user_id: self.username_id, success: { (JSONResponse) -> Void in
//                print(JSONResponse)
                let searchUserResponse = Mapper<SearchUserResponse>().map(JSONString: JSONResponse.rawString()!)
                if searchUserResponse != nil {
                    self.data += search2ObjectHelper(searchResponse: searchUserResponse!)
                }
                self.adapter.performUpdates(animated: true)
            }, failure: { JSONResponse in
                print(JSONResponse)
                ifLoginRequire(viewController: self)
            })
        } else {
            insta.searchUserFriendshipFollowing(query: quest, user_id: self.username_id, success: { (JSONResponse) -> Void in
//                print(JSONResponse)
                let searchUserResponse = Mapper<SearchUserResponse>().map(JSONString: JSONResponse.rawString()!)
                if searchUserResponse != nil {
                    self.data += search2ObjectHelper(searchResponse: searchUserResponse!)
                }
                self.adapter.performUpdates(animated: true)
            }, failure: { JSONResponse in
                print(JSONResponse)
                ifLoginRequire(viewController: self)
            })
        }
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
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
                    if self.next_max_id != "" {
                        if self.type == "Follower" {
                            self.followerJSON2ObjectPagination()
                        } else {
                            self.followingJSON2ObjectPagination()
                        }
                    }
                    self.adapter.performUpdates(animated: true, completion: nil)
                }
            }
        }
    }
    
    func searchSectionController(_ sectionController: SearchBarSectionController, didChangeText text: String) {
        data.removeAll()
        self.next_max_id = ""
        if text != "" {
            searchUsers(quest: text)
        } else {
            setup()
        }
        adapter.performUpdates(animated: true, completion: nil)
    }
}
