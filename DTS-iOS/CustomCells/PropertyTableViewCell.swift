    //
//  PropertyTableViewCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 04/04/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import QuartzCore

protocol PropertyTableViewCellDelegate {
    func didSelected(tag: NSInteger)
}

class PropertyTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var imgViewNewTop: UIImageView!
    @IBOutlet weak var ivStamp: UIImageView!
    @IBOutlet weak var lblBathrooms: UILabel!
    @IBOutlet weak var lblBedrooms: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var cvBG: UICollectionView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var viewCounter: UIView!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var ivBG: UIImageView!
    var delegate: PropertyTableViewCellDelegate?
    var bgImages = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadImages(images: NSArray) -> Void {
        self.bgImages = images
        self.cvBG.reloadData()
    }
    
    func maskImage(image:UIImage, mask:(UIImage))->UIImage{
        
        let imageReference = image.CGImage
        let maskReference = mask.CGImage
        
        let imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference!),
                                          CGImageGetHeight(maskReference!),
                                          CGImageGetBitsPerComponent(maskReference!),
                                          CGImageGetBitsPerPixel(maskReference!),
                                          CGImageGetBytesPerRow(maskReference!),
                                          CGImageGetDataProvider(maskReference!)!, nil, true)
        
        let maskedReference = CGImageCreateWithMask(imageReference!, imageMask!)
        
        let maskedImage = UIImage(CGImage:maskedReference!)
        
        return maskedImage
    }
    
    // Mark: - UICollectionView
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, 300)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bgImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("bgCell", forIndexPath: indexPath) as! BgCollectionViewCell
        let dictImage = self.bgImages[indexPath.row] as! NSDictionary
        let imgURL = dictImage["img_url"]!["md"] as! String
        
        cell.imgView.sd_setImageWithURL(NSURL(string: imgURL))
        let imgMask = UIImage(named: "mask-1024.png")
        let imgViewMask = UIImageView(image: imgMask!)
        cell.imgView.layoutIfNeeded()
        imgViewMask.frame = cell.imgView.bounds
        imgViewMask.contentMode = .ScaleToFill
        cell.imgView.backgroundColor = UIColor.blackColor()
        cell.imgView.layer.mask = imgViewMask.layer
        cell.imgView.setNeedsDisplay()
        
        //self.lblCounter.text = ("\(indexPath.item + 1)/\(self.bgImages.count)")


        cell.superview?.superview?.clipsToBounds = false
        cell.superview?.clipsToBounds = false
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let x = self.cvBG.contentOffset.x
        let w = self.cvBG.bounds.size.width
        let currentPage = Int(ceil(x/w))
        print("Current Page: \(currentPage)")
        self.lblCounter.text = ("\(currentPage + 1)/\(self.bgImages.count)")
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.delegate != nil {
            self.delegate?.didSelected(self.tag)
        }
    }
    

}
    

