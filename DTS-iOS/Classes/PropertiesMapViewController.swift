//
//  PropertiesMapViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 15/04/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

protocol MapPropertiesDelegate {
    func didListingButtonTappe(properties: NSMutableArray)
}

class PropertiesMapViewController: BaseViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var btnNearMe: UIButton!
    @IBOutlet weak var cvConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var cvMapProperty: UICollectionView!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var mapBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    var properties: NSMutableArray!
    var dictProperty: NSDictionary!
    var searchController: SearchPropertiesViewController?
    var hud: MBProgressHUD!
    var delegate: MapPropertiesDelegate?
    var swipeGesture: UISwipeGestureRecognizer!
    var annTag = 0
    var reqType = 2
    var selectedRow: Int?
    var originalURL = "https://api.ditchthe.space/api/getproperty?page=1"
    var mainData: NSDictionary?
    var nextURL: String?
    var isAnnotationTappedAlready: Bool!
    
    private var responseData:NSMutableData?
    private var dataTask:NSURLSessionDataTask?
    
    
    
    @IBAction func btnListing_Tapped(sender: AnyObject) {
        UIView.transitionWithView((self.navigationController?.view)!, duration: 0.5, options: .TransitionFlipFromLeft, animations: {
            if self.delegate != nil {
                self.delegate?.didListingButtonTappe(self.properties)
            }
            self.navigationController?.popToRootViewControllerAnimated(false)
        }) { (completed: Bool) in
            
        }
    }
    
    func hideMap(gesture: AnyObject) -> Void {
        self.view.layoutIfNeeded()
        self.cvConstraintHeight.constant = 0
        
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isAnnotationTappedAlready = false
        self.swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideMap(_:)))
        swipeGesture.direction = .Down
        self.cvMapProperty.addGestureRecognizer(self.swipeGesture)
        
        cvConstraintHeight.constant = 0
        self.btnNearMe.hidden = true
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        let centerCoordinate = AppDelegate.returnAppDelegate().selectedCoordinates!
        
        print(AppDelegate.returnAppDelegate().selectedCoordinates!)
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                /**centerCoordinate = CLLocationCoordinate2DMake(NSUserDefaults.standardUserDefaults().doubleForKey("selectedLat"), NSUserDefaults.standardUserDefaults().doubleForKey("selectedLong"))*/
                let selectedRegionWithAbb = selectedRegion.stringByReplacingOccurrencesOfString(", United States", withString: "")
                self.btnNearMe.setTitle(selectedRegionWithAbb, forState: .Normal)
                self.btnNearMe.hidden = false
            }
        }
        self.mapView.centerCoordinate = centerCoordinate
        let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 25000, 25000)
        self.mapView.setRegion(region, animated: true)
        self.btnAccount.hidden = true
        
        self.addAnnotationsToMap()
        self.cvMapProperty.reloadData()
        
    }
    
    func addAnnotationsToMap() -> Void {
        annTag = 0
        
        for dict in properties {
            let latitude = Double(dict["latitude"] as! String)
            let longitude = Double(dict["longitude"] as! String)
            
            let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            let imgURL = dict["img_url"]!!["md"] as! String
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                let finalImage = self.ResizeImage(image, targetSize: CGSizeMake(50, 30))
                let price = String(dict["price"] as! Int)
                let bed = String(dict["bed"] as! Int)
                let subTitle = ("\(bed)BR $\(price)/\(dict["term"] as! String)")
                
                let priceNumber = NSNumber.init(integer: dict["price"] as! Int)
                let shortPrice = Utils.suffixNumber(priceNumber)
                
                let annotaion = PropertyAnnotation(coordinate: coordinate, title: dict["title"] as! String, subtitle: subTitle, img: finalImage, withPropertyDictionary: dict as! NSDictionary, andTag: self.annTag, andPrice: shortPrice as String, andType: dict["type"] as? String)
                self.annTag = self.annTag + 1
                print("property title: ")
                print("lat: \(annotaion.coordinate.latitude), long: \(annotaion.coordinate.longitude)")
                self.mapView.addAnnotation(annotaion)
            })
            
        }
    }

    func getProperties(strURL: String) -> Void {
        
        self.hud.show(true)
        var strURL = "\(strURL)&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&show_owned_only=0&show_active_only=1&latitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)&longitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)"
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("\(strURL)&token=\(token)&show_owned_only=0&show_active_only=1&latitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)&longitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)")
        }
        
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
                if tempData != nil {
                    if tempData!["error"] as? String != nil {
                        let error = tempData!["error"] as! String
                        if error == "user_not_found" {
                            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token")
                            AppDelegate.returnAppDelegate().logOut()
                            return
                        }
                    }
                }
                let isSuccess = Bool(tempData!["success"] as! Int)
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.mainData = tempData!["data"] as? NSDictionary
                self.nextURL = self.mainData!["next_page_url"] as? String
                self.properties = self.mainData!["data"]?.mutableCopy() as! NSMutableArray
                
                    dispatch_async(dispatch_get_main_queue(), {
                        self.view.layoutIfNeeded()
                        self.cvConstraintHeight.constant = 0
                        
                        UIView.animateWithDuration(0.2) {
                            self.view.layoutIfNeeded()
                        }
                        
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        
                        //self.addAnnotationsToMap()
                        self.cvMapProperty.reloadData()
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - MapView
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let customAnnotation = annotation as! PropertyAnnotation
        let reuseId = "property"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = false
//            anView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
            
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView!.annotation = annotation
        }
        
        
        
//        anView?.addSubview(tempView)
        
        
        anView?.tag = customAnnotation.anTag
        anView?.image = getImageFromCustomView(customAnnotation.price!, withColor: "01c8ff", andType: customAnnotation.type!) //screenShot//?.imageWithAlpha(0.6)
//        anView?.image = customAnnotation.img
//        anView?.layer.borderWidth = 1
//        anView?.layer.borderColor = UIColor.whiteColor().CGColor
        return anView
 
    }
    
    func getImageFromCustomView(price: String, withColor color: String, andType type: String) -> UIImage? {
        let tempFrame = CGRectMake(0, 0, 60, 60)
        let tempView = UIView(frame: tempFrame)
        tempView.layer.cornerRadius = tempView.frame.size.width / 2
        //tempView.backgroundColor = UIColor(hexString: color)
        tempView.layer.borderWidth = 2
        tempView.layer.borderColor = UIColor(hexString: "7a7974").CGColor
        tempView.clipsToBounds = true
        tempView.backgroundColor = UIColor.clearColor()
        
        let middleView = UIView(frame: tempFrame)
        middleView.backgroundColor = UIColor(hexString: color)
        middleView.alpha = 0.6
        tempView.addSubview(middleView)
        
        
        let lblFrame = CGRectMake(5, 5, 50, 50)
        let lblPrice = UILabel(frame: lblFrame)
        lblPrice.textAlignment = .Center
        lblPrice.text = price
        lblPrice.textColor = UIColor.whiteColor()
        lblPrice.font = UIFont.boldSystemFontOfSize(17)
        tempView.addSubview(lblPrice)
        
        if type == "SUBLET" {
            let frameViewSub = CGRectMake(15, 0, 30, 16)
            let viewSub = UIView(frame: frameViewSub)
            viewSub.backgroundColor = UIColor.greenColor()
            
            let lblSubFrame = CGRectMake(0, 3, 30, 12)
            let lblSub = UILabel(frame: lblSubFrame)
            lblSub.font = UIFont.boldSystemFontOfSize(10)
            lblSub.textAlignment = .Center
            lblSub.textColor = UIColor.whiteColor()
            lblSub.backgroundColor = UIColor.clearColor()
            lblSub.text = "SUB"
            viewSub.addSubview(lblSub)
            tempView.addSubview(viewSub)
        }
        
        //let tempSize = CGSizeMake(50, 50)
        
        //UIGraphicsBeginImageContext(tempView.bounds.size)
        UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, false, 3)
        tempView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return screenShot
    }
    
//    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
//        if fullyRendered == true {
//            self.addAnnotationsToMap()
//        }
//    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        var indexPath = NSIndexPath(forItem: view.tag, inSection: 0)
        
        if self.isAnnotationTappedAlready == false {
            self.isAnnotationTappedAlready = true
            self.view.layoutIfNeeded()
            self.cvConstraintHeight.constant = 300
            
            UIView.animateWithDuration(0.2) {
                self.view.layoutIfNeeded()
            }
            //self.cvMapProperty.reloadData()
        }
        
        //view.image = getImageFromCustomView(customAnnotation.price!, withColor: "01c8ff")
        
        var selectedAnnotation: PropertyAnnotation?
        
        for i in 0..<mapView.annotations.count {
            let annotation = mapView.annotations[i] as! PropertyAnnotation
            if let annotationView = mapView.viewForAnnotation(annotation) {
                annotationView.layer.borderColor = UIColor.whiteColor().CGColor
                annotationView.image = getImageFromCustomView(annotation.price!, withColor: "01c8ff", andType: annotation.type!)
                
            }
            if annotation.anTag == view.tag {
                view.image = self.getImageFromCustomView(annotation.price!, withColor: "ff0000", andType: annotation.type!)
                selectedAnnotation = annotation
            }
        }
        
        
        
        
//        let dictPropertyAnn = self.properties[view.tag] as! NSDictionary
        view.layer.borderColor = UIColor.redColor().CGColor
        
//        let annMTitle = dictPropertyAnn["title"] as! String
//        let annPrice = String(dictPropertyAnn["price"] as! Int)
//        let annTitle = ("$\(annPrice)/\(dictPropertyAnn["term"]!)")
        var index = 0
        for lDictProperty in self.properties {
            
            let price = String(lDictProperty["price"] as! Int)
            let bed = String(lDictProperty["bed"] as! Int)
            let title = ("\(bed)BR $\(price)/\(lDictProperty["term"] as! String)")
            let mTitle = lDictProperty["title"] as! String
            
            
            if title == selectedAnnotation?.subtitle! && mTitle == selectedAnnotation?.title {
                
                

                let selectedAnnotationCoordinate = selectedAnnotation!.coordinate
                self.mapView.setCenterCoordinate(selectedAnnotationCoordinate, animated: true)
                
                
                indexPath = NSIndexPath(forItem: index, inSection: 0)
                self.cvMapProperty.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
                
                self.view.layoutIfNeeded()
                self.cvConstraintHeight.constant = 300
            
                UIView.animateWithDuration(0.2) {
                    self.view.layoutIfNeeded()
                }
            }
            
            index += 1
        }
        
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let customAnnotation = view.annotation as! PropertyAnnotation
        self.dictProperty = customAnnotation.dictProperty
        self.performSegueWithIdentifier("mapToDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapToSignup" {
            let controller = segue.destinationViewController as! SignUpViewController
            controller.propertyId = String(dictProperty["id"] as! Int)
            controller.reqType = reqType
            //controller.delegate = self
        }
        else {
            let controller = segue.destinationViewController as! PropertyDetailViewController
            controller.propertyID = String(dictProperty["id"] as! Int)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnAccount_Tapped(sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    

    
    @IBAction func btnSearch_Tapped(sender: AnyObject) {
        
        //        if searchController == nil {
        //            searchController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchPropertiesVC") as? SearchPropertiesViewController
        //            searchController?.delegate = self
        //            searchController?.isPropertySearch = true
        //        }
        
        
        searchController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchPropertiesVC") as? SearchPropertiesViewController
        searchController?.delegate = self
        searchController?.isPropertySearch = true
        self.navigationController?.presentViewController(searchController!, animated: true, completion: nil)
        //        self.performSegueWithIdentifier("propertiesVCToSearchProperties", sender: self)
    }
    
    func createAgentSearch() -> Void {
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                let selectedRegionWithAbb = selectedRegion.stringByReplacingOccurrencesOfString(", United States", withString: "")
                self.btnNearMe.setTitle(selectedRegionWithAbb, forState: .Normal)
                self.btnNearMe.hidden = false
            }
        }
        
        var strURL = "https://api.ditchthe.space/api/createusersearch?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&create_search_agent=1"
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/createusersearch?token=\(token)&create_search_agent=1")
        }
        
//        let dictAgentOptions = NSUserDefaults.standardUserDefaults().objectForKey("agentOptions") as! NSDictionary
        
        let body: NSDictionary = [
//            "schedule": dictAgentOptions,
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        self.hud.show(true)
        
        do {
            let jsonParamsData = try NSJSONSerialization.dataWithJSONObject(body, options: [])
            
            let url = NSURL(string: strURL)
            let request = NSMutableURLRequest(URL: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "POST"
            request.HTTPBody = jsonParamsData
            
            let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                if error == nil {
                    do {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hud.hide(true)
                        })
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                        let tempData = json as? NSDictionary
                    if tempData != nil {
                        if tempData!["error"] as? String != nil {
                            let error = tempData!["error"] as! String
                            if error == "user_not_found" {
                                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token")
                                AppDelegate.returnAppDelegate().logOut()
                                return
                            }
                        }
                    }
                    let isSuccess = Bool(tempData!["success"] as! Int)
                    
                    if isSuccess == false {
                        self.hud.hide(true)
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    
                    
                    self.properties = NSMutableArray()
                    self.getUserSearchByData(tempData!["data"] as! String)
                        
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
        catch {
            
        }
        
    }
    
    func createUserSearch() -> Void {
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                let selectedRegionWithAbb = selectedRegion.stringByReplacingOccurrencesOfString(", United States", withString: "")
                self.btnNearMe.setTitle(selectedRegionWithAbb, forState: .Normal)
                self.btnNearMe.hidden = false
            }
        }
        
        var strURL = "https://api.ditchthe.space/api/createusersearch?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&create_search_agent=0"
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/createusersearch?token=\(token)&create_search_agent=0")
        }
        
        let body: NSDictionary = [
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        
        
        self.hud.show(true)
        
        do {
            let jsonParamsData = try NSJSONSerialization.dataWithJSONObject(body, options: [])
            
            let url = NSURL(string: strURL)
            let request = NSMutableURLRequest(URL: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "POST"
            request.HTTPBody = jsonParamsData
            
            let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                if error == nil {
                    do {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hud.hide(true)
                        })
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                        let tempData = json as? NSDictionary
                        if tempData != nil {
                            if tempData!["error"] as? String != nil {
                                let error = tempData!["error"] as! String
                                if error == "user_not_found" {
                                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token")
                                    AppDelegate.returnAppDelegate().logOut()
                                    return
                                }
                            }
                        }
                        let isSuccess = Bool(tempData!["success"] as! Int)
                        
                        if isSuccess == false {
                            self.hud.hide(true)
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        
                        self.properties = NSMutableArray()
                        self.getUserSearchByData(tempData!["data"] as! String)
                        
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
        catch {
            
        }
    }
    
    func getUserSearchByData(data: String) -> Void {
        var strURL = "https://api.ditchthe.space/api/getsearchresults?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&type=user_searches&search_agent=0&key=\(data)&from_date=2016-01-01%2000%3A00%3A00&to_date=2018-01-01%2023%3A59%3A59"
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getsearchresults?token=\(token)&type=user_searches&search_agent=0&key=\(data)&from_date=2016-01-01%2000%3A00%3A00&to_date=2018-01-01%2023%3A59%3A59")
        }
        
        
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
                if tempData != nil {
                    if tempData!["error"] as? String != nil {
                        let error = tempData!["error"] as! String
                        if error == "user_not_found" {
                            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token")
                            AppDelegate.returnAppDelegate().logOut()
                            return
                        }
                    }
                }
                let isSuccess = Bool(tempData!["success"] as! Int)
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.mainData = tempData!["data"] as? NSDictionary
                
                if let userSearches = self.mainData!["user_searches"] as? NSArray {
                    
                    if let dictSearch = userSearches[0] as? NSDictionary {
                        if let results = dictSearch["results"] as? NSArray {
                            if let dictSearchFields = results[0] as? NSDictionary {
                                if let details = dictSearchFields["details"] as? NSArray {
                                    for dictProperty in details {
                                        if let dictPropertyFields = dictProperty["propertyFields"] as? NSDictionary {
                                            if dictPropertyFields["latitude"] as? String != nil {
                                                self.properties.addObject(dictPropertyFields)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    let centerCoordinate = CLLocationCoordinate2DMake(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude, (AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!)
                    
                    self.mapView.centerCoordinate = centerCoordinate
//                    let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 25000, 25000)
//                    self.mapView.setRegion(region, animated: true)
                    self.addAnnotationsToMap()
                    self.cvMapProperty.reloadData()
//                    let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 5000, 5000)
//                    self.mapView.setRegion(region, animated: true)
                    
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
    
    @IBAction func btnLike_Tapped(sender: AnyObject) {
        let btn = sender as! UIButton
        self.dictProperty = self.properties[btn.tag] as! NSDictionary
        self.selectedRow = btn.tag
        if NSUserDefaults.standardUserDefaults().objectForKey("token") == nil {
            reqType = 2
            self.performSegueWithIdentifier("mapToSignup", sender: self)
        }
        else {
            let propertyCell = self.cvMapProperty.cellForItemAtIndexPath(NSIndexPath(forItem: self.selectedRow!, inSection: 0)) as! MapPropertyCollectionViewCell
            
            if propertyCell.btnLike.selected == false {
                propertyCell.btnLike.selected = true
            }
            else {
                propertyCell.btnLike.selected = false
            }
            
            
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            self.likeProperty(token, propertyId: String(dictProperty["id"] as! Int))
        }
    }
    
    func getPropertyForLike(propertyID: String, selectedIndex: Int) -> Void {
        var strURL = "https://api.ditchthe.space/api/getproperty?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&property_id=\(propertyID)&show_owned_only=0&show_active_only=1"
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getproperty?token=\(token)&property_id=\(propertyID)&show_owned_only=0&show_active_only=1")
        }
        
        
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
                
                let dictData = tempData!["data"]!["data"] as! NSArray
                let dictProperty = dictData[0] as! NSDictionary
                self.properties.replaceObjectAtIndex(selectedIndex, withObject: dictProperty)
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
    
    func likeProperty(token: String, propertyId: String) -> Void {
        let strURL = ("https://api.ditchthe.space/api/likeproperty?token=\(token)&property_id=\(propertyId)")
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let dict = json as? NSDictionary
                if dict!["success"] as! Bool == true {
                    //self.getProperties()
                    self.getPropertyForLike(propertyId, selectedIndex: self.selectedRow!)
                }
                else {
                    let propertyCell = self.cvMapProperty.cellForItemAtIndexPath(NSIndexPath(forItem: self.selectedRow!, inSection: 0)) as! MapPropertyCollectionViewCell
                    propertyCell.btnLike.selected = false
                    let _utils = Utils()
                    self.hud.hide(true)
                    _utils.showOKAlert("Error:", message: dict!["message"] as! String, controller: self, isActionRequired: false)
                }
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
    
}

extension PropertiesMapViewController: SearchPropertiesDelegate {
    func didPressedDoneButton(isAgent: Bool) {
        
        if isAgent == false {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "searchType")
            self.createUserSearch()
        }
        else {
            NSUserDefaults.standardUserDefaults().setInteger(2, forKey: "searchType")
            self.createAgentSearch()
        }
    }
}

extension PropertiesMapViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let dictProperty = self.properties[indexPath.row] as? NSDictionary {
            AppDelegate.returnAppDelegate().isNewProperty = nil
            
            let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as? PropertyDetailViewController
            
            detailController!.propertyID = String(dictProperty["id"] as! Int)
            detailController!.dictProperty = dictProperty
            detailController!.isFromMainView = true
            self.navigationController?.pushViewController(detailController!, animated: true)
        }
    }
}

extension PropertiesMapViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(UIScreen.mainScreen().bounds.width, 300)
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.properties.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("mapCell", forIndexPath: indexPath) as! MapPropertyCollectionViewCell
        
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        if let bgImages = dictProperty["imgs"] as? NSArray {
            
            let dictImage = bgImages[0] as! NSDictionary
            let imgURL = dictImage["img_url"]!["md"] as! String
            cell.ivBg.sd_setImageWithURL(NSURL(string: imgURL))
            
        }
        
        let priceNumber = NSNumber.init(integer: dictProperty["price"] as! Int)
        let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
        cell.lblTitle.text = ("$\(price)/\(dictProperty["term"]!)")
        cell.lblTitle.textColor = UIColor(hexString: "02ce37")
        cell.lblAddress.text = (dictProperty["address1"] as? String)?.capitalizedString
        cell.lblSqFt.text = "SQ Ft. \(dictProperty["lot_size"] as! Int)"
        
        cell.ivStamp.hidden = true
        
        if Bool(dictProperty["inquired"] as! Int) == true {
            cell.ivStamp.hidden = false
        }
        
        let bath = String(dictProperty["bath"] as! Int)
        let bed = String(dictProperty["bed"] as! Int)
        
        cell.lblBath.text = bath
        cell.lblBedroom.text = bed
        
        cell.btnLike.addTarget(self, action: #selector(ViewController.btnLike_Tapped(_:)), forControlEvents: .TouchUpInside)
        cell.btnLike.selected = false
        let isLiked = dictProperty["liked"] as! Bool
        if isLiked == true {
            cell.btnLike.selected = true
        }
        
        
        cell.btnLike.tag = indexPath.row
        
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let x = self.cvMapProperty.contentOffset.x
        let w = self.cvMapProperty.bounds.size.width
        let currentPage = Int(ceil(x/w))
        
        
        let dictPropertyAnn = self.properties[currentPage] as! NSDictionary
        let annPrice = String(dictPropertyAnn["price"] as! Int)
        let bed = String(dictPropertyAnn["bed"] as! Int)
        let annTitle = ("\(bed)BR $\(annPrice)/\(dictPropertyAnn["term"]!)")
        let annMTtitle = dictPropertyAnn["title"] as! String
        
        
        for i in 0..<self.mapView.annotations.count {
            let selectedAnnotation = self.mapView.annotations[i] as! PropertyAnnotation
            if annTitle == selectedAnnotation.subtitle! && annMTtitle == selectedAnnotation.title! {
                self.mapView.selectAnnotation(selectedAnnotation, animated: false)
                break
            }
        }
    }

}

extension PropertiesMapViewController: SignupViewControllerDelegate {
    func didSignedUpSuccessfully() {
        showHideBottomBar()
        let propertyCell = self.cvMapProperty.cellForItemAtIndexPath(NSIndexPath(forItem: self.selectedRow!, inSection: 0)) as! MapPropertyCollectionViewCell
        propertyCell.btnLike.selected = true
        self.properties = NSMutableArray()
        self.getProperties(self.originalURL)
        
    }
    
    func showHideBottomBar() -> Void {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
