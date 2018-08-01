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

class NewsViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    var data: [ListDiffable] = []
    var next_max_id = 0
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
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
//        switch object {
//        case is UserInfo: return UserInfoHeaderSectionController()
//        default: return UserInfoPostSectionController()
//        }
        return NewsSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func getNews() {
        insta.getNews(success: {(JSONResponse) -> Void in
            print(JSONResponse)
            let newsResponse = Mapper<NewsResponse>().map(JSONString: JSONResponse.rawString()!)
            if newsResponse?.next_max_id != nil {
                self.next_max_id = (newsResponse?.next_max_id)!
            }
            if newsResponse?.stories != nil {
                for item in (newsResponse?.stories)! {
                    let news = News(type: (item.type)!, profile_image: (item.args?.profile_image)!, text: (item.args?.text)!)
                    self.data.append(news)
                }
            }
            self.adapter.performUpdates(animated: true)
        }, failure: { (JSONResponse) in
            print(JSONResponse)
        })
    }
    
    func getInbox() {
        insta.getNewsInbox(success: {(JSONResponse) -> Void in
            print(JSONResponse)
        }, failure: { (JSONResponse) in
            print(JSONResponse)
        })
    }
    
}
