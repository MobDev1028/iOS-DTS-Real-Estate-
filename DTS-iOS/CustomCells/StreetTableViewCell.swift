//
//  StreetTableViewCell.swift
//  DTS-iOS
//
//  Created by mobile on 11/6/16.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreMotion


class StreetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var streetViewLayer: UIView!
    @IBOutlet weak var streetView: GMSPanoramaView!
    @IBOutlet weak var mapViewLayer: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var mapChangeButton: UIButton!
    @IBOutlet weak var flickButton: UIButton!
    
    
    var isStreetView = false
    var isFlick = false
    var lat = 0.0
    var long = 0.0
    
    var orientation : GMSOrientation!
    let motionManager = CMMotionManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        showStreeView()
        startGryo()
        
    }
    
    func showStreeView() {
        self.mapViewLayer.hidden = true
        self.streetViewLayer.hidden = false
        self.streetView.moveNearCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: long))
        
        self.mapChangeButton.setBackgroundImage(UIImage(named: "ico-streetview-flatmap"), forState: UIControlState.Normal)
    }
    
    func showMapView() {
        self.mapViewLayer.hidden = false
        self.streetViewLayer.hidden = true
        let camera = GMSCameraPosition.cameraWithLatitude(lat,
                                                          longitude: long, zoom:16)
        self.mapView.camera = camera
        let position = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: position)
        marker.map = self.mapView
        
        self.mapChangeButton.setBackgroundImage(UIImage(named: "ico-streetview-streetmap"), forState: UIControlState.Normal)
        
    }
    
    @IBAction func changeMap(sender: AnyObject) {
        if isStreetView {
            
            showStreeView()
        } else{
            showMapView()
        }
        
        isStreetView = !isStreetView
        
    }
    
    @IBAction func changeFlick(sender: AnyObject) {
        
        if isFlick {
            self.flickButton.setBackgroundImage(UIImage(named: "ico-streetview-flickpan-on"), forState: UIControlState.Normal)
            self.streetView.setAllGesturesEnabled(true)
            self.mapView.userInteractionEnabled = true
        } else{
            self.flickButton.setBackgroundImage(UIImage(named: "ico-streetview-flickpan"), forState: UIControlState.Normal)
            self.streetView.setAllGesturesEnabled(false)
            self.mapView.userInteractionEnabled = false
            if orientation != nil {
                self.streetView.animateToCamera(GMSPanoramaCamera(orientation: orientation, zoom: 1.0), animationDuration: 0)
            }
            
        }
        
        isFlick = !isFlick
    }
    
    func startGryo()  {
        
        var delta = 0.0
        var y = 0.0
        
        if self.motionManager.gyroAvailable {
            
            if !self.motionManager.gyroActive {
                
                self.motionManager.startGyroUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) in
                    
                    let currentY = (data?.rotationRate.y)!
                    
                    delta = currentY - y
                    
                    if fabs(delta) >= 0.01{
                        let updatedCamera = GMSPanoramaCameraUpdate.rotateBy(-CGFloat(currentY))
                        self.orientation = GMSOrientation(heading: CLLocationDirection(currentY), pitch: 0)
                        
                        if self.isFlick {
                            self.streetView.updateCamera(updatedCamera, animationDuration: 0)
                            
                        }
                        
                        y = currentY
                    }
                    
                })
            }
        }
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
