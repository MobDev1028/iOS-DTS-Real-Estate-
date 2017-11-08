//
//  DetailTableViewCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 04/04/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreMotion

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMoveInCost: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblSecurityDeposit: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblSqrFeetCaption: UILabel!
    @IBOutlet weak var lblBathCaption: UILabel!
    @IBOutlet weak var lblBedCaption: UILabel!
    @IBOutlet weak var lblAddressLine2: UILabel!
    @IBOutlet weak var viewDetail: UIView!
    @IBOutlet weak var lblprice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblBeds: UILabel!
    @IBOutlet weak var lblBaths: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var cvBG: UICollectionView!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var viewCounter: UIView!
    
    var isUCLPreview: Bool?
    var bgImages = []
    var lat = 0.0
    var long = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    func showMap() -> Void {
        let camera = GMSCameraPosition.cameraWithLatitude(lat,
                                                          longitude: long, zoom:16)
        self.mapView.camera = camera
        let position = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: position)
        marker.map = self.mapView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension DetailTableViewCell: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bgImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("bgCell", forIndexPath: indexPath) as! DetailBGCollectionViewCell
        
        cell.setUp()
        
        if isUCLPreview == nil {
            let dictImage = self.bgImages[indexPath.row] as! NSDictionary
            let imgURL = dictImage["img_url"]!["md"] as! String
            cell.imgView.sd_setImageWithURL(NSURL(string: imgURL))
        }
        else {
            cell.imgView.image = self.bgImages[indexPath.row] as? UIImage
        }

        
        cell.imgView.setNeedsDisplay()
        cell.imgView.clipsToBounds = true
        //        self.lblCounter.text = ("\(indexPath.item + 1)/\(self.bgImages.count)")
        
        
        return cell
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let x = self.cvBG.contentOffset.x
        let w = self.cvBG.bounds.size.width
        let currentPage = Int(ceil(x/w))
        print("Current Page: \(currentPage)")
        self.lblCounter.text = ("\(currentPage + 1)/\(self.bgImages.count)")
        
    }
}

extension DetailTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height)
    }
}


