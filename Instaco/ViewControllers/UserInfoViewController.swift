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
    var data: [ListDiffable] = []
    var postData: [UserFeed] = []
    var postDataId: [String] = []
    var next_max_id = ""
    var loading = false
    var friendshipflag: FriendshipResponse?
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    private let refreshControl = FixedRefreshControl()
    
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
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                let keychain = Keychain(service: "com.instacoapp")
                try keychain.removeAll()
                
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
    
    func setup(friendship: FriendshipResponse) {
        getUserInfoHeader(success: { (JSONResponse) in
            var is_private = false
            let userInfoResponse = Mapper<UserInfoResponse>().map(JSONString: JSONResponse.rawString()!)
            if (userInfoResponse?.user?.is_private)! == 0 {
                is_private = false
            } else {
                is_private = true
            }
            let userInfo = UserInfo(username: (userInfoResponse?.user?.username)!,
                                    userProfileImage: URL(string: (userInfoResponse?.user?.hd_profile_pic_url_info?.url)!)!,
                                    full_name: (userInfoResponse?.user?.full_name)!,
                                    biography: (userInfoResponse?.user?.biography)!,
                                    profileImageimageHeight: (userInfoResponse?.user?.hd_profile_pic_url_info?.height)!,
                                    profileImageimageWidth: (userInfoResponse?.user?.hd_profile_pic_url_info?.width)!,
                                    follower_count: (userInfoResponse?.user?.follower_count)!,
                                    following_count: (userInfoResponse?.user?.following_count)!,
                                    is_private: is_private,
                                    external_url: (userInfoResponse?.user?.external_url)!,
                                    pk: (userInfoResponse?.user?.pk)!,
                                    media_count: (userInfoResponse?.user?.media_count)!,
                                    friendship: friendship.following!)
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
            let friendshipResponse = Mapper<FriendshipResponse>().map(JSONString: JSONResponse.rawString()!)
            self.friendshipflag = friendshipResponse
            self.setup(friendship: friendshipResponse!)
        }, failure: { (JSONResponse) -> Void in
            print(JSONResponse)
        })
    }
    
    func getUserInfoFeed() {
        if self.next_max_id == "" {
            insta.getUserFeed(userid: self.username_id, success: {(JSONResponse) -> Void in
//                print(JSONResponse)
                let userFeedResponse = Mapper<UserFeedResponse>().map(JSONString: JSONResponse.rawString()!)
                if userFeedResponse?.next_max_id != nil {
                    self.next_max_id = (userFeedResponse?.next_max_id)!
                }
                if userFeedResponse?.items != nil {
                    self.postData.removeAll()
                    for item in (userFeedResponse?.items!)! {
                        if self.postDataId.index(of: item.id!) == nil {
                            let userFeed = UserFeed(imageURL: URL(string: item.image_versions2![0].url!)!, imageHeight: item.image_versions2![0].height!, imageWidth: item.image_versions2![0].height!, id: item.id!)
                            self.postData.append(userFeed)
                            self.postDataId.append(item.id!)
                        }
                    }
                }

                self.data.append(GridItem(items: self.postData))
                self.adapter.performUpdates(animated: true)
                
                self.refreshControl.endRefreshing()
            }, failure: { (JSONResponse) -> Void in
                print(JSONResponse)
            })
        } else {
            insta.getUserFeed(userid: self.username_id, max_id: self.next_max_id, success: {(JSONResponse) -> Void in
//                print(JSONResponse)
                let userFeedResponse = Mapper<UserFeedResponse>().map(JSONString: JSONResponse.rawString()!)
                if userFeedResponse?.next_max_id != nil {
                    self.next_max_id = (userFeedResponse?.next_max_id)!
                }
                if userFeedResponse?.items != nil {
                    self.postData.removeAll()
                    for item in (userFeedResponse?.items!)! {
                        if self.postDataId.index(of: item.id!) == nil {
                            let userFeed = UserFeed(imageURL: URL(string: item.image_versions2![0].url!)!, imageHeight: item.image_versions2![0].height!, imageWidth: item.image_versions2![0].height!, id: item.id!)
                            self.postData.append(userFeed)
                            self.postDataId.append(item.id!)
                        }
                    }
                }
                
                self.data.append(GridItem(items: self.postData))
                self.adapter.performUpdates(animated: true)
                
                self.refreshControl.endRefreshing()
            }, failure: { (JSONResponse) -> Void in
                print(JSONResponse)
            })
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is UserInfo: return UserInfoHeaderSectionController()
        default: return UserInfoPostSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    @objc private func refreshUserInfoData(_ sender: Any) {
        data.removeAll()
        postData.removeAll()
        postDataId.removeAll()
        self.next_max_id = ""
        getFriendship()
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
