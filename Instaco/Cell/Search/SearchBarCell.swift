//
//  SearchBarCell.swift
//  Instaco
//
//  Created by Henry Lin on 8/2/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit

final class SearchBarCell: UICollectionViewCell {
    
    lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.autocapitalizationType = .none
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = contentView.bounds
    }
    
}
