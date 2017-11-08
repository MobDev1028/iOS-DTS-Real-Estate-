//
//  StreetViewController.swift
//  DTS-iOS
//
//  Created by mac on 11/8/16.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreMotion

class StreetViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var streetView: GMSPanoramaView!
    @IBOutlet weak var flickButton: UIButton!
    @IBOutlet weak var mapChangeButton: UIButton!
    
    
    var lat = 0.0
    var long = 0.0
    var isStreetView = false
    var isFlick = false
    
    var orientation : GMSOrientation!
    var motionManager = CMMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        showStreeView()
        startGryo()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showStreeView() {
        self.mapView.hidden = true
        self.streetView.hidden = false
        self.streetView.moveNearCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: long))
        
        self.mapChangeButton.setBackgroundImage(UIImage(named: "ico-streetview-flatmap"), forState: UIControlState.Normal)
        
    }
    
    func showMapView() {
        self.mapView.hidden = false
        self.streetView.hidden = true
        let camera = GMSCameraPosition.cameraWithLatitude(lat,
                                                          longitude: long, zoom: 16)
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
    
    
    @IBAction func changeFullScreen(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
