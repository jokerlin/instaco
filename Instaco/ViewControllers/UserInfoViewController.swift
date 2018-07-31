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

class UserInfoViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var data = [ListDiffable]()
    var next_max_id = ""
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        self.view.addSubview(collectionView)
        
        getUserInfoHeader()
        
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func getUserInfoHeader() {
        insta.getUserInfo(userid: insta.username_id, success: { (JSONResponse) in
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
                                    media_count: (userInfoResponse?.user?.media_count)!)
            self.data.append(userInfo)
            self.navigationItem.title = userInfo.username
            self.adapter.performUpdates(animated: true)
        }, failure: { (JSONResponse) in
            print(JSONResponse)
        })
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
//        switch object{
//        case is UserInfo: return UserInfoHeaderSectionController()
//        default: return UserInfoPostSectionController()
//        }
        return UserInfoHeaderSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}
