//
//  MediaVideoCell.swift
//  Instaco
//
//  Created by Henry Lin on 8/6/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import SDWebImage
import IGListKit
import Player

final class VideoCell: UICollectionViewCell, ListBindable {
    var player = Player()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.backgroundColor = .clear
        print(contentView.bounds)
        player.view.frame = contentView.bounds
        contentView.addSubview(self.player.view)
        player.playbackLoops = true
        player.muted = true
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard viewModel is VideoViewModel else { return }
    }
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        if player.muted == true {
            player.muted = false
        } else {
            player.muted = true
        }
    }
}