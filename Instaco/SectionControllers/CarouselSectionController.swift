//
//  CarouselSectionController.swift
//  Instaco
//
//  Created by Henry Lin on 8/6/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import IGListKit

final class CarouselSectionController: ListSectionController, ImageCellDelegate {
    private var url: String?
    
    override init() {
        super.init()
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: ImageCell.self, for: self, at: index) as? ImageCell else {
            fatalError()
        }
        cell.imageView.sd_setImage(with: URL(string: url!))
        cell.delegate = self
        return cell
    }
    
    override func didUpdate(to object: Any) {
        url = object as? String
    }
    
    // MARK: ImageCellDelegate
    
    func didLongPressImage(cell: ImageCell) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Save to Camera Roll", style: .default, handler: { (_) in
            
            let selector = #selector(self.onCompleteCapture(image:error:contextInfo:))
            UIImageWriteToSavedPhotosAlbum(cell.imageView.image!, self, selector, nil)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func onCompleteCapture(image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            print("Save Successfully")
            let alertController = UIAlertController(title: "Successfully saved", message: nil, preferredStyle: .alert)
            viewController?.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.viewController?.dismiss(animated: false, completion: nil)
            }
        } else {
            print("Save Fail")
            let alertController = UIAlertController(title: "Failed to save", message: "Please enable camera roll access in Settings", preferredStyle: .alert)
            viewController?.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.viewController?.dismiss(animated: false, completion: nil)
            }
        }
    }

}
