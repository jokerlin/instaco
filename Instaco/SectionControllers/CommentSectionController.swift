//
//  CommentSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 8/11/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

class CommentSectionController: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource, PostCommentCellDelegate {
    
    var comment: Comment?
    
    override init() {
        super.init()
        dataSource = self
    }
    
    // MARK: ListBindingSectionController
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? Comment else { fatalError() }
        comment = object
        return [object]
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        guard let cell = collectionContext!.dequeueReusableCell(of: PostCommentCell.self, for: self, at: index) as? UICollectionViewCell & ListBindable
            else { fatalError("Cell not bindable") }
        if let cell = cell as? PostCommentCell {
            cell.delegate = self
        }
        return cell
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        let height: CGFloat = PostCommentCell.textHeight((comment?.text)!, width: width) + 32 + 5 + 5
        return CGSize(width: width, height: height)
    }
    
    // MARK: PostCommentCellDelegate
    
    func didTapUsername(cell: PostCommentCell) {
        let userInfoViewController = UserInfoViewController(username_id: String((comment?.user_id)!))
        viewController?.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
}
