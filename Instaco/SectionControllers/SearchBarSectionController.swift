//
//  SearchBarSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 8/2/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

protocol SearchSectionControllerDelegate: class {
    func searchSectionController(_ sectionController: SearchBarSectionController, didChangeText text: String)
}

final class SearchBarSectionController: ListSectionController, UISearchBarDelegate, ListScrollDelegate {
    
    weak var delegate: SearchSectionControllerDelegate?
    
    override init() {
        super.init()
        scrollDelegate = self
    }
    
    // MARK: ListSectionController
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 44)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: SearchBarCell.self, for: self, at: index) as? SearchBarCell else {
            fatalError()
        }
        cell.searchBar.delegate = self
        return cell
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchSectionController(self, didChangeText: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.searchSectionController(self, didChangeText: searchBar.text!)
    }
    
    // MARK: ListScrollDelegate
    
    func listAdapter(_ listAdapter: ListAdapter, didScroll sectionController: ListSectionController) {
        if let searchBar = (collectionContext?.cellForItem(at: 0, sectionController: self) as? SearchBarCell)?.searchBar {
            searchBar.resignFirstResponder()
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willBeginDragging sectionController: ListSectionController) {}
    func listAdapter(_ listAdapter: ListAdapter,
                     didEndDragging sectionController: ListSectionController,
                     willDecelerate decelerate: Bool) {}
    
}
