//
//  PropertyDetailTableViewCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 27/10/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class PropertyDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivBG: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 5
        self.scrollView.delegate = self
        self.scrollView.userInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PropertyDetailTableViewCell.zoom(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTap)
        
    }
    
    func zoom(tapGesture: UITapGestureRecognizer) {
        if (self.scrollView!.zoomScale == self.scrollView!.minimumZoomScale) {
            let center = tapGesture.locationInView(self.scrollView!)
            let size = self.ivBG!.image!.size
            let zoomRect = CGRectMake(center.x, center.y, (size.width / 3), (size.height / 3))
            self.scrollView!.zoomToRect(zoomRect, animated: true)
        } else {
            self.scrollView!.setZoomScale(self.scrollView!.minimumZoomScale, animated: true)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension PropertyDetailTableViewCell: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.ivBG
    }
}
