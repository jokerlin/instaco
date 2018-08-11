//
//  NewsViewController.swift
//  Instaco
//
//  Created by Henry Lin on 8/1/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import IGListKit
import ObjectMapper
import SwiftyJSON

// FOR FUTURE USE
// CODE IS OUTDATED
class NewsViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var newsData = [ListDiffable]()
    var inboxData = [ListDiffable]()
    var data = [ListDiffable]()
    var next_max_id = 0
    var continuation_token = 0
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    private let refreshControl = FixedRefreshControl()
    let segments: [(String, String)] = [
        ("News", "news"),
        ("Inbox", "inbox")
    ]
    var selectedClass: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let control = UISegmentedControl(items: segments.map { return $0.0 })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(onControl(_:)), for: .valueChanged)
        navigationItem.titleView = control
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        self.view.addSubview(collectionView)
        getNews()
        // getInbox()
        
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return NewsSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func getNews() {
        insta.getNews(success: {(JSONResponse) -> Void in
//            print(JSONResponse)
            let newsResponse = Mapper<NewsResponse>().map(JSONString: JSONResponse.rawString()!)
            if newsResponse?.next_max_id != nil {
                self.next_max_id = (newsResponse?.next_max_id)!
            }
            if newsResponse?.stories != nil {
                for item in (newsResponse?.stories)! {
                    let news = News(type: (item.type)!, profile_image: (item.args?.profile_image)!, text: (item.args?.text)!)
                    self.newsData.append(news)
                }
            }
            self.data = self.newsData
            self.adapter.performUpdates(animated: true)
            self.refreshControl.endRefreshing()
        }, failure: { (JSONResponse) in
            ifLoginRequire(viewController: self)
            print(JSONResponse)
        })
    }
    
    func getInbox() {
        self.adapter.performUpdates(animated: true)
        insta.getNewsInbox(success: {(JSONResponse) -> Void in
            print(JSONResponse)
            let inboxResponse = Mapper<InboxResponse>().map(JSONString: JSONResponse.rawString()!)
            if inboxResponse?.continuation_token != nil {
                self.continuation_token = (inboxResponse?.continuation_token)!
            }
            if inboxResponse?.new_stories != nil {
                for item in (inboxResponse?.new_stories)! {
                    let news = News(type: (item.type)!, profile_image: (item.args?.profile_image)!, text: (item.args?.text)!)
                    self.inboxData.append(news)
                }
            }
            
            if inboxResponse?.old_stories != nil {
                for item in (inboxResponse?.old_stories)! {
                    let news = News(type: (item.type)!, profile_image: (item.args?.profile_image)!, text: (item.args?.text)!)
                    self.inboxData.append(news)
                }
            }
            self.data = self.inboxData
            self.adapter.performUpdates(animated: true)
            self.refreshControl.endRefreshing()
            
        }, failure: { (JSONResponse) in
            ifLoginRequire(viewController: self)
            print(JSONResponse)
        })
    }
    
    @objc private func refreshNewsData(_ sender: Any) {
        if selectedClass == "news" {
            newsData.removeAll()
            getNews()
        } else {
            inboxData.removeAll()
            getInbox()
        }
    }
    
    @objc func onControl(_ control: UISegmentedControl) {
        selectedClass = segments[control.selectedSegmentIndex].1
        if selectedClass == "news" {
            data.removeAll()
            if data.count == 0 {
                getNews()
            }
        } else {
            data.removeAll()
            if data.count == 0 {
                getInbox()
            }
        }
    }
}
