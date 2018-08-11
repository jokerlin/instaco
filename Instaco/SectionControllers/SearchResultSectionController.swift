//
//  SearchResultSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 8/2/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

class SearchResultSectionController: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource {
    
    override init() {
        super.init()
        dataSource = self
    }
    
    // MARK: ListBindingSectionController
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? SearchUserModel else { fatalError() }
        return [object]
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        guard let cell = collectionContext!.dequeueReusableCell(of: SearchResultCell.self, for: self, at: index) as? UICollectionViewCell & ListBindable
            else { fatalError("Cell not bindable") }
        return cell
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        let height: CGFloat = 50
        return CGSize(width: width, height: height)
    }
    
    override func didSelectItem(at index: Int) {
        let searchUser = object as! SearchUserModel
        let userInfoViewController = UserInfoViewController(username_id: String((searchUser.pk)))
        viewController?.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
}
