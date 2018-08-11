//
//  UserInfoViewController.swift
//  Instaco
//
//  Created by Henry Lin on 7/29/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import ObjectMapper
import KeychainAccess

class UserInfoViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var username_id: String = ""
    var data: [Any] = []
    var postData: [UserFeed] = []
    var postDataId: [String] = []
    var next_max_id = ""
    var loading = false
    var friendshipflag: ObjectFriendshipResponse?
    private let refreshControl = FixedRefreshControl()
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    init(username_id id: String) {
        super.init(nibName: nil, bundle: nil)
        username_id = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshUserInfoData(_:)), for: .valueChanged)
        self.view.addSubview(collectionView)
        
        getFriendship()
        if username_id == insta.username_id {
            setupLogOutButton()
        }
        
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
        postData.removeAll()
        postDataId.removeAll()
        self.next_max_id = ""
        getFriendship()
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try insta.logout(success: {_ in
                    print("Logout " + insta.username)
                    
                    // Set insta object
                    insta.isLoggedIn = false
                    insta.error = ""
                    
                    // Set keychain
                    let keychain = Keychain(service: "com.instacoapp")
                    try! keychain.removeAll()
                    
                }, failure: {JSONResponse in
                    print(JSONResponse)
                })
                
                // present signout controller
                let loginContoller = LoginController()
                let navController = UINavigationController(rootViewController: loginContoller)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to sign out: ", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    func setup(friendship: ObjectFriendshipResponse) {
        getUserInfoHeader(success: { (JSONResponse) in
            let userInfoResponse = Mapper<ObjectUserInfoResponse>().map(JSONString: JSONResponse.rawString()!)
            
            var is_private = false
            if userInfoResponse?.user?.is_private != nil {
                is_private = (userInfoResponse?.user?.is_private)! == 0 ? false: true
            }
            let userInfo = UserInfo(username: userInfoResponse?.user?.username ?? "",
                                    userProfileImage: URL(string: (userInfoResponse?.user?.hd_profile_pic_url_info?.url) ?? "")!,
                                    full_name: userInfoResponse?.user?.full_name ?? "",
                                    biography: userInfoResponse?.user?.biography ?? "",
                                    profileImageimageHeight: userInfoResponse?.user?.hd_profile_pic_url_info?.height ?? 0,
                                    profileImageimageWidth: userInfoResponse?.user?.hd_profile_pic_url_info?.width ?? 0,
                                    follower_count: userInfoResponse?.user?.follower_count ?? 0,
                                    following_count: userInfoResponse?.user?.following_count ?? 0,
                                    is_private: is_private,
                                    external_url: userInfoResponse?.user?.external_url ?? "",
                                    pk: userInfoResponse?.user?.pk ?? 0,
                                    media_count: userInfoResponse?.user?.media_count ?? 0,
                                    friendship: friendship)
            self.data.append(userInfo)
            
            self.navigationItem.title = userInfo.username
            self.getUserInfoFeed()
        }, failure: { (JSONResponse) in
            print(JSONResponse)
        })
    }
    
    func getUserInfoHeader(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        insta.getUserInfo(userid: self.username_id, success: success, failure: failure)
    }
    
    func getFriendship() {
        insta.getUserFriendship(userid: self.username_id, success: { (JSONResponse) -> Void in
//            print(JSONResponse)
            let friendshipResponse = Mapper<ObjectFriendshipResponse>().map(JSONString: JSONResponse.rawString()!)
            self.friendshipflag = friendshipResponse
            if let friendship = friendshipResponse {
                self.setup(friendship: friendship)
            }
        }, failure: { (JSONResponse) -> Void in
            ifLoginRequire(viewController: self)
            print(JSONResponse)
        })
    }
    
    func getUserInfoFeed() {
        if self.next_max_id == "" {
            insta.getUserFeed(userid: self.username_id, success: {(JSONResponse) -> Void in
//                print(JSONResponse)
                self.getUserFeedHelper(JSONResponse: JSONResponse)
                
                // If no Posts, show some tips
                if self.postData.count == 0 {
                    self.data.append("No posts here.")
                    self.adapter.performUpdates(animated: true, completion: nil)
                }
            }, failure: { (JSONResponse) -> Void in
                print(JSONResponse)
                // is private account
                if insta.error.contains("Not authorized to view user") {
                    print("THIS IS A PRIVATE ACCOUNT")
                    self.data.append("This is a private account.")
                    self.adapter.performUpdates(animated: true, completion: nil)
                }
            })
        } else {
            insta.getUserFeed(userid: self.username_id, max_id: self.next_max_id, success: {(JSONResponse) -> Void in
//                print(JSONResponse)
                self.getUserFeedHelper(JSONResponse: JSONResponse)
            }, failure: { (JSONResponse) -> Void in
                print(JSONResponse)
            })
        }
    }
    
    func getUserFeedHelper(JSONResponse: JSON) {
        let userFeedResponse = Mapper<ObjectUserFeedResponse>().map(JSONString: JSONResponse.rawString()!)
        self.next_max_id = userFeedResponse?.next_max_id ?? self.next_max_id
        if let items = userFeedResponse?.items {
            self.postData.removeAll()
            for item in items where item.id != nil && item.image_versions2 != nil && item.type != nil {
                if self.postDataId.index(of: item.id!) == nil {
                    let userFeed = UserFeed(imageURL: URL(string: item.image_versions2![0].url ?? "")!,
                                            imageHeight: item.image_versions2![0].height ?? 0,
                                            imageWidth: item.image_versions2![0].height ?? 0,
                                            id: item.id!,
                                            type: item.type!)
                    self.postData.append(userFeed)
                    self.postDataId.append(item.id!)
                }
            }
        }
        
        self.data.append(GridItem(items: self.postData))
        self.adapter.performUpdates(animated: true)
        self.refreshControl.endRefreshing()
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as! [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is UserInfo: return UserInfoHeaderSectionController()
        case is String: return TipSectionController()
        default: return UserInfoPostSectionController()
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
                        self.setup(friendship: self.friendshipflag!)
                    }
                    self.adapter.performUpdates(animated: true, completion: nil)
                    
                }
            }
        }
        
    }
}
