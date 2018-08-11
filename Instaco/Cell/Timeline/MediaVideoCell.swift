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
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        
        switch self.player.playbackState.rawValue {
        case PlaybackState.stopped.rawValue:
            self.player.playFromBeginning()
        case PlaybackState.paused.rawValue:
            self.player.playFromCurrentTime()
        default:
            if player.muted == true {
                player.muted = false
            } else {
                player.muted = true
            }
        }
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard viewModel is VideoViewModel else { return }
    }
}
