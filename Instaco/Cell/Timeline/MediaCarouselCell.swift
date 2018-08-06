//
//  MediaCarouselCell.swift
//  Instaco
//
//  Created by Henry Lin on 8/5/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import SDWebImage
import IGListKit
import SnapKit

final class MediaCarouselCell: UICollectionViewCell, UIScrollViewDelegate, ListBindable {
    
    var data: [String] = []
//    var scrollDelegate: UIScrollViewDelegate
    
    lazy var carousel: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.bounces = false
        return view
    }()
    
    public lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
//        control.numberOfPages = 3
//        control.currentPage = 0
        control.hidesForSinglePage = true
        control.pageIndicatorTintColor = .lightGray
        control.currentPageIndicatorTintColor = UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0)
        return control
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        scrollDelegate = self
        contentView.addSubview(carousel)
        contentView.addSubview(pageControl)
        contentView.bringSubview(toFront: pageControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        carousel.frame = contentView.frame
        pageControl.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView.snp.bottom).offset(20)
            make.centerX.equalTo(contentView)
        }
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? MediaCarouselViewModel else { return }
        self.data = viewModel.urls
    }
}
