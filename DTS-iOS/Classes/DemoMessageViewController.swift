//
//  DemoMessageViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 21/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MapKit

import MBProgressHUD

class DemoMessageViewController: BaseViewController {
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var tvReply: UITextView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var ivProperty: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    var dictSelectedMessage: NSDictionary!
    var dictProperty: NSDictionary!
    var hud: MBProgressHUD!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.returnAppDelegate().isBack = true
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        self.populateFields()
        
        self.btnAccount.hidden = true
        
        self.btnDecline.hidden = false
        self.btnAccept.hidden = false
        self.btnAccept.enabled = true
        if dictSelectedMessage["accepted"] as! Int != 0 {
            self.btnAccept.setTitle("Already accepted", forState: .Normal)
            self.btnDecline.hidden = true
            self.btnAccept.enabled = false
            
        }
        else if dictSelectedMessage["declined"] as! Int != 0 {
            self.btnDecline.setTitle("Declined", forState: .Normal)
            self.btnAccept.hidden = true
        }
        
        let latitude = Double(dictProperty["latitude"] as! String)
        let longitude = Double(dictProperty["longitude"] as! String)
        
        let centerCoordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        self.mapView.centerCoordinate = centerCoordinate
        let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 500, 500)
        self.mapView.setRegion(region, animated: true)
        let finalImage = UIImage(named: "account-gear.png")
        
        
        let annotaion = PropertyAnnotation(coordinate: centerCoordinate, title: "", subtitle: "", img: finalImage!, withPropertyDictionary: dictSelectedMessage, andTag: 0, andPrice: nil, andType: "")
        self.mapView.addAnnotation(annotaion)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(DemoMessageViewController.sendBack))
        swipeGesture.direction = .Right
        self.view.addGestureRecognizer(swipeGesture)
    }
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func logoButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func sendBack() -> Void {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnAccount_Tapped(sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func acceptMessage() -> Void {
        let msgID = String(dictSelectedMessage["id"] as! Int)
        
        
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/updatemsg?token=\(token)&msg_id=\(msgID)&action=accept")
        }
        
        self.hud.show(true)
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let tempData = json as? NSDictionary
                let isSuccess = Bool(tempData!["success"] as! Int)
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                
                }
                catch {
                    
                }

            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }
        dataTask.resume()
        
    }
    
    func declineMessage() -> Void {
        let msgID = String(dictSelectedMessage["id"] as! Int)
        
        
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/updatemsg?token=\(token)&msg_id=\(msgID)&action=decline")
        }
        
        self.hud.show(true)
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let tempData = json as? NSDictionary
                let isSuccess = Bool(tempData!["success"] as! Int)
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
                catch {
                    
                }

            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)

            }
        }
        dataTask.resume()
        
    }


    @IBAction func btnAccept_Tapped(sender: AnyObject) {
        self.acceptMessage()
    }
    @IBAction func btnDecline_Tapped(sender: AnyObject) {
        self.declineMessage()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    func populateFields() -> Void {
        self.lblSubject.textColor = UIColor(hexString: "ff0500")
        if dictSelectedMessage["type"] as! String == "doc_sign" {
            self.lblSubject.text = "SIGN LEASE"
        }
        else if dictSelectedMessage["type"] as! String == "follow_up" {
            self.lblSubject.text = "FOLLOW UP"
            
        }
        else if dictSelectedMessage["type"] as! String == "demo" {
            self.lblSubject.text = "ON-SITE DEMO"
            
        }
        else if dictSelectedMessage["type"] as! String == "inquire" {
            self.lblSubject.text = "INQUIRED"
            self.lblSubject.textColor = UIColor(hexString: "02ce37")
            
        }
        else {
            self.lblSubject.text = dictSelectedMessage["type"]!.uppercaseString
            
        }
        
        let address1 = dictProperty["address1"] as! String
        let city = dictProperty["city"] as! String
        let state = dictProperty["state_or_province"] as! String
        let zip = dictProperty["zip"] as! String
        
        self.lblAddress.text = address1
        self.lblCountry.text = "\(city), \(state) \(zip)"
        self.lblMessage.text = dictSelectedMessage["content"] as? String
        let imgURL = dictProperty["img_url"]!["sm"] as! String
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
            self.ivProperty.image = image
        })
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "property"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            
        }
        else {
            anView!.annotation = annotation
        }
        
        return anView
        
    }
    @IBAction func btnMap_Tapped(sender: AnyObject) {
        var address = dictProperty["address"] as! String
        address =  address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: ("https://maps.apple.com/?address=\(address)"))
        UIApplication.sharedApplication().openURL(url!)
    }

    @IBAction func btnProperty_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

extension DemoMessageViewController: MKMapViewDelegate {
    
}

