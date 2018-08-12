//
//  CommentViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/11/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

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

class CommentViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var media_id: String = ""
    var next_min_id = ""
    var next_min_id_pre = ""
    var loading = false
    var data = [ListDiffable]()
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let refreshControl = FixedRefreshControl()
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    init(media_id id: String) {
        super.init(nibName: nil, bundle: nil)
        media_id = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        collectionView.keyboardDismissMode = .interactive
        self.view.addSubview(collectionView)
        
        commentJSON2Object()
        
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc private func refreshData(_ sender: Any) {
        data.removeAll()
        self.next_min_id = ""
        commentJSON2Object()
    }
    
    func commentJSON2Object() {
        insta.getMediaComments(media_id: self.media_id, success: { JSONResponse in
            let commentResponse = Mapper<ObjectCommentResponse>().map(JSONString: JSONResponse.rawString()!)
            if commentResponse?.next_min_id != nil {
                self.next_min_id = (commentResponse?.next_min_id)!
            }
            if commentResponse?.comments != nil {
                for comment in (commentResponse?.comments)! {
                    let c = Comment(username: comment.user?.username ?? "",
                        profile_image: comment.user?.profile_pic_url ?? "",
                        user_id: comment.user?.pk ?? 0,
                        text: comment.text ?? "",
                        comment_like_count: comment.comment_like_count ?? 0,
                        timestamp: comment.created_at_utc ?? 0,
                        has_liked_comment: comment.has_liked_comment ?? false)
                    self.data.append(c)
                }
            }
            self.adapter.performUpdates(animated: true, completion: nil)
        }, failure: { JSONResponse in
            print(JSONResponse)
        })
    }
    
    func commentJSON2ObjectPagination(next_min_id: String) {
        insta.getMediaComments(media_id: self.media_id, next_min_id: self.next_min_id, success: { JSONResponse in
            let commentResponse = Mapper<ObjectCommentResponse>().map(JSONString: JSONResponse.rawString()!)
            if commentResponse?.next_min_id != nil {
                self.next_min_id_pre = self.next_min_id
                self.next_min_id = (commentResponse?.next_min_id)!
            }
            if commentResponse?.comments != nil {
                for comment in (commentResponse?.comments)! {
                    let c = Comment(username: comment.user?.username ?? "",
                                    profile_image: comment.user?.profile_pic_url ?? "",
                                    user_id: comment.user?.pk ?? 0,
                                    text: comment.text ?? "",
                                    comment_like_count: comment.comment_like_count ?? 0,
                                    timestamp: comment.created_at_utc ?? 0,
                                    has_liked_comment: comment.has_liked_comment ?? false)
                    self.data.append(c)
                }
            }
            self.adapter.performUpdates(animated: true, completion: nil)
        }, failure: { JSONResponse in
            print(JSONResponse)
        })
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
        //        return data as! [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return CommentSectionController()
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
                    if self.next_min_id != "" && self.next_min_id_pre != self.next_min_id {
                        self.commentJSON2ObjectPagination(next_min_id: self.next_min_id)
                        self.adapter.performUpdates(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
