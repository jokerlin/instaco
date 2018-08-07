//
//  UserInfoHeaderSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 7/30/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

class UserInfoHeaderSectionController: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource, UserInfoHeaderCellDelegate {
    
    var userInfo: UserInfo?
    var followFlagChange: Bool = false
    
    override init() {
        super.init()
        dataSource = self
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? UserInfo else { fatalError() }
        userInfo = object
        return [object]
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        guard let cell = collectionContext!.dequeueReusableCell(of: UserInfoHeaderCell.self, for: self, at: index) as? UICollectionViewCell & ListBindable
            else { fatalError("Cell not bindable") }
        if let cell = cell as? UserInfoHeaderCell {
            cell.delegate = self
        }
        return cell
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        let height: CGFloat = 180 + UserInfoHeaderCell.textHeight((userInfo?.biography)!, width: width)
        return CGSize(width: width, height: height)
    }
    
    func didTapFollow(cell: UserInfoHeaderCell) {
        if userInfo?.friendship == true {
            if followFlagChange == false {
                followFlagChange = true
                cell.followButton.setTitle("follow", for: .normal)
                insta.FollowOp(type: false, user_id: String(userInfo!.pk))
            } else {
                followFlagChange = false
                cell.followButton.setTitle("Following", for: .normal)
                insta.FollowOp(type: true, user_id: String(userInfo!.pk))
            }
        } else {
            if followFlagChange == false {
                followFlagChange = true
                cell.followButton.setTitle("Following", for: .normal)
                insta.FollowOp(type: true, user_id: String(userInfo!.pk))
            } else {
                followFlagChange = false
                cell.followButton.setTitle("follow", for: .normal)
                insta.FollowOp(type: false, user_id: String(userInfo!.pk))
            }
        }
        update(animated: true)
    }
}
