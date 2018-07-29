//
//  TimelineCommentSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 7/29/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class TimelineCommentSectionController: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource{
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        <#code#>
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        <#code#>
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        <#code#>
    }
    
    
}
