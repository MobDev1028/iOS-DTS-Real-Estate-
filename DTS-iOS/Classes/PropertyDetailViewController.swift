//
//  PropertyDetailViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 04/04/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD
import GoogleMaps


class PropertyDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var btnRequestInfo: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var viewCall: UIView!
    @IBOutlet weak var btnAccount: UIButton!
    var dictProperty: NSDictionary!
    var images = []
    @IBOutlet weak var tblDetailBottomConstraint: NSLayoutConstraint!
    var reqType = 0
    var hud: MBProgressHUD!
    var propertyID: String!
    var propertyImages: NSMutableArray!
    @IBOutlet weak var tblDetail: UITableView!
    var isFromMainView: Bool?
    var amenities = ""
    var highlights = ""
    private let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    var driveDuration: String?
    var distance: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.returnAppDelegate().isBack = true
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        self.btnAccount.hidden = true
        
        if let revealController = revealViewController() {
            revealController.panGestureRecognizer().enabled = false
        }
        
        self.tblDetail.estimatedRowHeight = 100.0
        self.tblDetail.rowHeight = UITableViewAutomaticDimension
        
        self.tabBarController?.tabBar.hidden = true
        self.view.layoutIfNeeded()
        
        self.getAddressFromCurrentLocation()
        
        
//        if self.isFromMainView == nil {
//            self.hud.show(true)
//            self.getProperty()
//        }
//        
////        let dictAuther = self.dictProperty["author_user_info"] as? NSDictionary
////        if dictAuther != nil {
////            let autherCID = dictAuther!["cid"] as? Int
////            if autherCID != nil {
////                if dictMetaData != nil {
////                    let dictUserInfo = dictMetaData!["user_info"] as? NSDictionary
////                    if dictUserInfo != nil {
////                        let userCID = dictUserInfo!["cid"] as? Int
////                        if userCID != nil {
////                            if autherCID == userCID {
////                                self.btnAccount.hidden = false
////                            }
////                        }
////                    }
////                }
////            }
////        }
//        
//        self.images = self.dictProperty["imgs"] as! NSArray
//        self.tblDetail.reloadData()
        
//        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
//            self.btnAccount.hidden = false
//        }
    }
    
    
    
    @IBAction func callButtonTapped(sender: AnyObject) {
        if let dictAuthour = self.dictProperty["author_user_info"] as? NSDictionary {
            if let phoneNumber = dictAuthour["cid"] as? String {
                if let url = NSURL(string: "tel://\(phoneNumber)") {
                    if UIApplication.sharedApplication().canOpenURL(url) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                    else {
                        Utils.showOKAlertRO("", message: "This device is not confgured to make call.", controller: self)
                    }
                }
            }
        }
    }
    
    @IBAction func requestInfoButtonTapped(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey("token") == nil {
            self.performSegueWithIdentifier("detailToSignUp", sender: self)
            reqType = 0
        }
        else {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            self.inquireProperty(token, propertyId: String(dictProperty["id"] as! Int))
        }
    }
    @IBAction func hideButtonTapped(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey("token") == nil {
            self.performSegueWithIdentifier("detailToSignUp", sender: self)
            reqType = 5
        }
        else {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            self.hideProperty(token, propertyId: String(dictProperty["id"] as! Int))
        }
    }
    @IBAction func backButtonTapped(sender: AnyObject) {
        if AppDelegate.returnAppDelegate().isNewProperty != nil {
            AppDelegate.returnAppDelegate().isNewProperty = false
            self.navigationController?.popViewControllerAnimated(true)
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    @IBAction func btnAccount_Tapped(sender: AnyObject) {
        self.deleteProperty()
    }
    
    func deleteProperty() -> Void {
        var strURL = ""
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/deleteproperty?token=\(token)&id=\(propertyID)")
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
                
                self.navigationController?.popToRootViewControllerAnimated(true)
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
        
//        self.hud.show(true)
//        self.getProperty()
        
        if self.isFromMainView == nil {
            self.hud.show(true)
            self.getProperty()
        }
        else {
            fillHighlights(self.dictProperty)
            fillAmenities(self.dictProperty)
            self.images = self.dictProperty["imgs"] as! NSArray
        }
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func getProperty() -> Void {
        var strURL = "https://api.ditchthe.space/api/getproperty?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&property_id=\(propertyID)&show_owned_only=0&show_active_only=0&show_reviewed_only=0"
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getproperty?token=\(token)&property_id=\(propertyID)&show_owned_only=0&show_active_only=0&show_reviewed_only=0&page=1")
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
                let arrData = tempData!["data"]!["data"] as! NSArray
                let dictMetaData = tempData!["metdata"] as? NSDictionary
                
                self.dictProperty = arrData[0] as! NSDictionary
                
                let dictAuther = self.dictProperty["author_user_info"] as? NSDictionary
                if dictAuther != nil {
                    let autherCID = dictAuther!["cid"] as? Int
                    if autherCID != nil {
                        if dictMetaData != nil {
                            let dictUserInfo = dictMetaData!["user_info"] as? NSDictionary
                            if dictUserInfo != nil {
                                let userCID = dictUserInfo!["cid"] as? Int
                                if userCID != nil {
                                    if autherCID == userCID {
                                       self.btnAccount.hidden = false
                                    }
                                }
                            }
                        }
                    }
                }
                
                self.images = self.dictProperty["imgs"] as! NSArray
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tblDetail.reloadData()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// Mark: - UITableView
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            if AppDelegate.returnAppDelegate().isNewProperty != nil {
//                return 495
//            }
//            return 680
//        }
//        else if indexPath.row == 1 {
//            return 175
//        }
//        else if indexPath.row == 2 {
//            return 215
//        }
//        return 300
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.images.count > 0 {
            if let provider = self.dictProperty["provider"] as? String {
                if provider == "listhub" {
                    return self.images.count + 6
                }
            }

            return self.images.count + 5
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let provider = self.dictProperty["provider"] as? String {
            if provider == "listhub" {
                if indexPath.row == 0 {
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell1", forIndexPath: indexPath) as! DetailTableViewCell
                        
                        
                        let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                        let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                        debugPrint("Lat: \(lat), Long: \(long)")
                        cell.lat = lat
                        cell.long = long
                        
                        cell.showMap()
                        
                        let imgURL = dictProperty["img_url"]!["md"] as! String
                        if AppDelegate.returnAppDelegate().isNewProperty != nil {
                            if AppDelegate.returnAppDelegate().isNewProperty! == true {
                                //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                                
                            }
                            else {
                                //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            }
                        }
                        else {
                            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                                //                        cell.imgView.image = image
                            })
                        }
                        
                        let price = String(dictProperty["price"] as! Int)
                        
                        cell.lblprice.text = ("$\(price ?? "")/\(self.dictProperty["term"] ?? "")")
                        
                        cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalizedString)"
                        cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalizedString), \((dictProperty["state_or_province"] as! String).uppercaseString), \((dictProperty["zip"] as! String).capitalizedString)"
                        
                        
                        let bath = String(dictProperty["bath"] as! Int)
                        let bed = String(dictProperty["bed"] as! Int)
                        
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBaths.text = ("\(bath) baths")
                        
                        cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                        cell.selectionStyle = .None
                        return cell
                    }
                    let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! DetailTableViewCell
                    _ = dictProperty["img_url"]!["md"] as! String
                    
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    
                    cell.showMap()
                    
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        if AppDelegate.returnAppDelegate().isNewProperty! == true {
                            //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                        }
                        else {
                            //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            
                        }
                    }
                    else {
                        cell.bgImages = self.images
                        
                    }
                    
                    cell.lblMoveInCost.text = "Free"
                    cell.lblSecurityDeposit.text = "Free"
                    
                    if let secDeposit = self.dictProperty["security_deposit"] as? Int {
                        cell.lblSecurityDeposit.text = "$\(secDeposit)"
                    }
                    
                    if let moveInCostCondition = self.dictProperty["move_in_cost"] as? String {
                        if moveInCostCondition.lowercaseString == "1st month only" {
                            if let price = self.dictProperty["price"] as? Int {
                                cell.lblMoveInCost.text = "$\(price)"
                            }
                        }
                        else if moveInCostCondition.lowercaseString == "1st month + sec deposit" {
                            if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                                let totalMoveInCost = price + secDeipost
                                cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                            }
                        }
                        else if moveInCostCondition.lowercaseString == "1st month + sec deposit + last month" {
                            if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                                let totalMoveInCost = (price * 2) + secDeipost
                                cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                            }
                        }
                    }
                    cell.viewCounter.layer.cornerRadius = 6
                    cell.viewCounter.clipsToBounds = true
                    
                    if self.driveDuration != nil {
                        cell.lblDuration.text = self.driveDuration
                    }
                    
                    
                    let x = cell.cvBG.contentOffset.x
                    let w = cell.cvBG.bounds.size.width
                    let currentPage = Int(ceil(x/w))
                    print("Current Page: \(currentPage)")
                    cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
                    
                    let price = String(dictProperty["price"] as! Int)
                    
                    if price.characters.count > 4 {
                        let priceNumber = NSNumber.init(integer: dictProperty["price"] as! Int)
                        let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                        cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                    }
                    else {
                        cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                    }
                    
                    cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalizedString)"
                    cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalizedString), \((dictProperty["state_or_province"] as! String).uppercaseString), \((dictProperty["zip"] as! String).capitalizedString)"
                    
                    let intBath = dictProperty["bath"] as! Int
                    let intBeds = dictProperty["bed"] as! Int
                    let bath = String(dictProperty["bath"] as! Int)
                    let bed = String(dictProperty["bed"] as! Int)
                    
                    //              _ = cell.imgView.image!
                    if intBeds > 1 {
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBedCaption.text = "Bed Rooms";
                    }
                    else {
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBedCaption.text = "Bed Room";
                    }
                    
                    if intBath > 1 {
                        cell.lblBaths.text = ("\(bath)")
                        cell.lblBathCaption.text = "Bath Rooms"
                    }
                    else {
                        cell.lblBaths.text = ("\(bath)")
                        cell.lblBathCaption.text = "Bath Room"
                    }
                    
                    cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                    cell.selectionStyle = .None
                    return cell
                }
                else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("StreetTableViewCell", forIndexPath: indexPath) as! StreetTableViewCell
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    cell.showStreeView()
                    cell.fullScreenButton.addTarget(self, action: #selector(PropertyDetailViewController.goStreetView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    
                    return cell
                }
                else if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                    cell.lblTitle.text = self.dictProperty["title"] as? String
                    cell.lblDescription.text = self.dictProperty["description"] as? String
                    cell.selectionStyle = .None
                    return cell
                }
                else if indexPath.row == 3 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("amenCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                    //            cell.lblDescription.text = self.dictProperty["description"] as? String
                    cell.lblPropertyHighlights.text = highlights
                    cell.lblDescription.text = amenities
                    cell.selectionStyle = .None
                    return cell
                }
                else if indexPath.row == self.images.count + 4 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("listhubCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                    cell.agentName.text = self.dictProperty["agent_name"] as? String
                    cell.lblBrokageOffice.text = self.dictProperty["brokerage_name"] as? String
                    cell.lblLink.text = self.dictProperty["redirect_url"] as? String
                    cell.selectionStyle = .None
                    return cell
                }
                else if indexPath.row == self.images.count + 5 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ReportTableViewCell
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! PropertyDetailTableViewCell
                    let dictImage = self.images[indexPath.row - 4] as! NSDictionary
                    let imgURL = dictImage["img_url"]!["md"] as! String
                    
                    
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        cell.ivBG.image = self.propertyImages[indexPath.row - 1] as? UIImage
                    }
                    else {
                        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                            cell.ivBG.image = image
                        })
                    }
                    
                    cell.ivBG.contentMode = .ScaleAspectFill
                    cell.ivBG.clipsToBounds = true
                    cell.selectionStyle = .None
                    return cell
                }
            }
            else {
                if indexPath.row == 0 {
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell1", forIndexPath: indexPath) as! DetailTableViewCell
                        
                        
                        let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                        let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                        debugPrint("Lat: \(lat), Long: \(long)")
                        cell.lat = lat
                        cell.long = long
                        
                        cell.showMap()
                        
                        let imgURL = dictProperty["img_url"]!["md"] as! String
                        if AppDelegate.returnAppDelegate().isNewProperty != nil {
                            if AppDelegate.returnAppDelegate().isNewProperty! == true {
                                //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                                
                            }
                            else {
                                //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            }
                        }
                        else {
                            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                                //                        cell.imgView.image = image
                            })
                        }
                        
                        let price = String(dictProperty["price"] as! Int)
                        
                        cell.lblprice.text = ("$\(price ?? "")/\(self.dictProperty["term"] ?? "")")
                        
                        cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalizedString)"
                        cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalizedString), \((dictProperty["state_or_province"] as! String).uppercaseString), \((dictProperty["zip"] as! String).capitalizedString)"
                        
                        
                        let bath = String(dictProperty["bath"] as! Int)
                        let bed = String(dictProperty["bed"] as! Int)
                        
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBaths.text = ("\(bath) baths")
                        
                        cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                        cell.selectionStyle = .None
                        return cell
                    }
                    let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! DetailTableViewCell
                    _ = dictProperty["img_url"]!["md"] as! String
                    
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    
                    cell.showMap()
                    
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        if AppDelegate.returnAppDelegate().isNewProperty! == true {
                            //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                        }
                        else {
                            //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            
                        }
                    }
                    else {
                        cell.bgImages = self.images
                        
                    }
                    
                    cell.lblMoveInCost.text = "Free"
                    cell.lblSecurityDeposit.text = "Free"
                    
                    if let secDeposit = self.dictProperty["security_deposit"] as? Int {
                        cell.lblSecurityDeposit.text = "$\(secDeposit)"
                    }
                    
                    if let moveInCostCondition = self.dictProperty["move_in_cost"] as? String {
                        if moveInCostCondition.lowercaseString == "1st month only" {
                            if let price = self.dictProperty["price"] as? Int {
                                cell.lblMoveInCost.text = "$\(price)"
                            }
                        }
                        else if moveInCostCondition.lowercaseString == "1st month + sec deposit" {
                            if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                                let totalMoveInCost = price + secDeipost
                                cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                            }
                        }
                        else if moveInCostCondition.lowercaseString == "1st month + sec deposit + last month" {
                            if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                                let totalMoveInCost = (price * 2) + secDeipost
                                cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                            }
                        }
                    }
                    cell.viewCounter.layer.cornerRadius = 6
                    cell.viewCounter.clipsToBounds = true
                    
                    if self.driveDuration != nil {
                        cell.lblDuration.text = self.driveDuration
                    }
                    
                    
                    let x = cell.cvBG.contentOffset.x
                    let w = cell.cvBG.bounds.size.width
                    let currentPage = Int(ceil(x/w))
                    print("Current Page: \(currentPage)")
                    cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
                    
                    let price = String(dictProperty["price"] as! Int)
                    
                    if price.characters.count > 4 {
                        let priceNumber = NSNumber.init(integer: dictProperty["price"] as! Int)
                        let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                        cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                    }
                    else {
                        cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                    }
                    
                    cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalizedString)"
                    cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalizedString), \((dictProperty["state_or_province"] as! String).uppercaseString), \((dictProperty["zip"] as! String).capitalizedString)"
                    
                    let intBath = dictProperty["bath"] as! Int
                    let intBeds = dictProperty["bed"] as! Int
                    let bath = String(dictProperty["bath"] as! Int)
                    let bed = String(dictProperty["bed"] as! Int)
                    
                    //              _ = cell.imgView.image!
                    if intBeds > 1 {
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBedCaption.text = "Bed Rooms";
                    }
                    else {
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBedCaption.text = "Bed Room";
                    }
                    
                    if intBath > 1 {
                        cell.lblBaths.text = ("\(bath)")
                        cell.lblBathCaption.text = "Bath Rooms"
                    }
                    else {
                        cell.lblBaths.text = ("\(bath)")
                        cell.lblBathCaption.text = "Bath Room"
                    }
                    
                    cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                    cell.selectionStyle = .None
                    return cell
                }
                else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("StreetTableViewCell", forIndexPath: indexPath) as! StreetTableViewCell
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    cell.showStreeView()
                    cell.fullScreenButton.addTarget(self, action: #selector(PropertyDetailViewController.goStreetView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    
                    return cell
                }
                else if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                    cell.lblTitle.text = self.dictProperty["title"] as? String
                    cell.lblDescription.text = self.dictProperty["description"] as? String
                    cell.selectionStyle = .None
                    return cell
                }
                else if indexPath.row == 3 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("amenCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                    //            cell.lblDescription.text = self.dictProperty["description"] as? String
                    cell.lblPropertyHighlights.text = highlights
                    cell.lblDescription.text = amenities
                    cell.selectionStyle = .None
                    return cell
                }
                else if indexPath.row == self.images.count + 4 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ReportTableViewCell
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! PropertyDetailTableViewCell
                    let dictImage = self.images[indexPath.row - 4] as! NSDictionary
                    let imgURL = dictImage["img_url"]!["md"] as! String
                    
                    
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        cell.ivBG.image = self.propertyImages[indexPath.row - 1] as? UIImage
                    }
                    else {
                        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                            cell.ivBG.image = image
                        })
                    }
                    
                    cell.ivBG.contentMode = .ScaleAspectFill
                    cell.ivBG.clipsToBounds = true
                    cell.selectionStyle = .None
                    return cell
                }
            }
        }
        else {
            if indexPath.row == 0 {
                if AppDelegate.returnAppDelegate().isNewProperty != nil {
                    let cell = tableView.dequeueReusableCellWithIdentifier("detailCell1", forIndexPath: indexPath) as! DetailTableViewCell
                    
                    
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    
                    cell.showMap()
                    
                    let imgURL = dictProperty["img_url"]!["md"] as! String
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        if AppDelegate.returnAppDelegate().isNewProperty! == true {
                            //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            
                        }
                        else {
                            //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                        }
                    }
                    else {
                        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                            //                        cell.imgView.image = image
                        })
                    }
                    
                    let price = String(dictProperty["price"] as! Int)
                    
                    cell.lblprice.text = ("$\(price ?? "")/\(self.dictProperty["term"] ?? "")")
                    
                    cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalizedString)"
                    cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalizedString), \((dictProperty["state_or_province"] as! String).uppercaseString), \((dictProperty["zip"] as! String).capitalizedString)"
                    
                    
                    let bath = String(dictProperty["bath"] as! Int)
                    let bed = String(dictProperty["bed"] as! Int)
                    
                    cell.lblBeds.text = ("\(bed)")
                    cell.lblBaths.text = ("\(bath) baths")
                    
                    cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                    cell.selectionStyle = .None
                    return cell
                }
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! DetailTableViewCell
                _ = dictProperty["img_url"]!["md"] as! String
                
                let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                debugPrint("Lat: \(lat), Long: \(long)")
                cell.lat = lat
                cell.long = long
                
                cell.showMap()
                
                if AppDelegate.returnAppDelegate().isNewProperty != nil {
                    if AppDelegate.returnAppDelegate().isNewProperty! == true {
                        //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                    }
                    else {
                        //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                        
                    }
                }
                else {
                    cell.bgImages = self.images
                    
                }
                
                cell.lblMoveInCost.text = "Free"
                cell.lblSecurityDeposit.text = "Free"
                
                if let secDeposit = self.dictProperty["security_deposit"] as? Int {
                    cell.lblSecurityDeposit.text = "$\(secDeposit)"
                }
                
                if let moveInCostCondition = self.dictProperty["move_in_cost"] as? String {
                    if moveInCostCondition.lowercaseString == "1st month only" {
                        if let price = self.dictProperty["price"] as? Int {
                            cell.lblMoveInCost.text = "$\(price)"
                        }
                    }
                    else if moveInCostCondition.lowercaseString == "1st month + sec deposit" {
                        if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                            let totalMoveInCost = price + secDeipost
                            cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                        }
                    }
                    else if moveInCostCondition.lowercaseString == "1st month + sec deposit + last month" {
                        if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                            let totalMoveInCost = (price * 2) + secDeipost
                            cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                        }
                    }
                }
                cell.viewCounter.layer.cornerRadius = 6
                cell.viewCounter.clipsToBounds = true
                
                if self.driveDuration != nil {
                    cell.lblDuration.text = self.driveDuration
                }
                
                
                let x = cell.cvBG.contentOffset.x
                let w = cell.cvBG.bounds.size.width
                let currentPage = Int(ceil(x/w))
                print("Current Page: \(currentPage)")
                cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
                
                let price = String(dictProperty["price"] as! Int)
                
                if price.characters.count > 4 {
                    let priceNumber = NSNumber.init(integer: dictProperty["price"] as! Int)
                    let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                    cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                }
                else {
                    cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                }
                
                cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalizedString)"
                cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalizedString), \((dictProperty["state_or_province"] as! String).uppercaseString), \((dictProperty["zip"] as! String).capitalizedString)"
                
                let intBath = dictProperty["bath"] as! Int
                let intBeds = dictProperty["bed"] as! Int
                let bath = String(dictProperty["bath"] as! Int)
                let bed = String(dictProperty["bed"] as! Int)
                
                //              _ = cell.imgView.image!
                if intBeds > 1 {
                    cell.lblBeds.text = ("\(bed)")
                    cell.lblBedCaption.text = "Bed Rooms";
                }
                else {
                    cell.lblBeds.text = ("\(bed)")
                    cell.lblBedCaption.text = "Bed Room";
                }
                
                if intBath > 1 {
                    cell.lblBaths.text = ("\(bath)")
                    cell.lblBathCaption.text = "Bath Rooms"
                }
                else {
                    cell.lblBaths.text = ("\(bath)")
                    cell.lblBathCaption.text = "Bath Room"
                }
                
                cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("StreetTableViewCell", forIndexPath: indexPath) as! StreetTableViewCell
                let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                debugPrint("Lat: \(lat), Long: \(long)")
                cell.lat = lat
                cell.long = long
                cell.showStreeView()
                cell.fullScreenButton.addTarget(self, action: #selector(PropertyDetailViewController.goStreetView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                cell.lblTitle.text = self.dictProperty["title"] as? String
                cell.lblDescription.text = self.dictProperty["description"] as? String
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("amenCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                //            cell.lblDescription.text = self.dictProperty["description"] as? String
                cell.lblPropertyHighlights.text = highlights
                cell.lblDescription.text = amenities
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == self.images.count + 4 {
                let cell = tableView.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ReportTableViewCell
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! PropertyDetailTableViewCell
                let dictImage = self.images[indexPath.row - 4] as! NSDictionary
                let imgURL = dictImage["img_url"]!["md"] as! String
                
                
                if AppDelegate.returnAppDelegate().isNewProperty != nil {
                    cell.ivBG.image = self.propertyImages[indexPath.row - 1] as? UIImage
                }
                else {
                    SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                        cell.ivBG.image = image
                    })
                }
                
                cell.ivBG.contentMode = .ScaleAspectFill
                cell.ivBG.clipsToBounds = true
                cell.selectionStyle = .None
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.images.count + 4 {
            self.reportProperty(String(dictProperty["id"] as! Int))
        }
    }
    
    // Mark: - Private Methods
    
    func goStreetView(sender: UIButton) -> Void  {
        self.performSegueWithIdentifier("streetView", sender: sender)
    }
    
    // Mark: - Private Methods
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailToSignUp" {
            let controller = segue.destinationViewController as! SignUpViewController
            controller.propertyId = String(dictProperty["id"] as! Int)
            controller.reqType = reqType
        }
        else if segue.identifier == "streetView"{
            let controller = segue.destinationViewController as! StreetViewController
            let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
            let long = (self.dictProperty["longitude"] as! NSString).doubleValue
            controller.lat = lat
            controller.long = long
        }
    }
    
    @IBAction func btnInstantApply_Tapped(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey("token") == nil {
            self.performSegueWithIdentifier("detailToSignUp", sender: self)
            reqType = 1
        }
    }
    
    @IBAction func btnRequestInfo_Tapped(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey("token") == nil {
            self.performSegueWithIdentifier("detailToSignUp", sender: self)
            reqType = 0
        }
        else {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            self.inquireProperty(token, propertyId: String(dictProperty["id"] as! Int))
        }
    }
    
//    func getDrivingTime() -> Void {
//        self.hud.show(true)
//        let strURL = ("https://api.ditchthe.space/api/inquireproperty?token=\(token)&property_id=\(propertyId)")
//        let url = NSURL(string: strURL)
//        let request = NSURLRequest(URL: url!)
//        
//        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
//            if error == nil {
//                do {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.hud.hide(true)
//                    })
//                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
//                    let dict = json as? NSDictionary
//                    if dict!["success"] as! Bool == true {
//                        //                    let detailCell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
//                        //
//                        //
//                        //                    detailCell.btnRequestInfo.setTitle("Info requested", forState: .Normal)
//                        //                    detailCell.btnRequestInfo.enabled = false
//                        NSUserDefaults.standardUserDefaults().setObject("yes", forKey: propertyId)
//                        NSUserDefaults.standardUserDefaults().synchronize()
//                    }
//                    else {
//                        let _utils = Utils()
//                        _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
//                    }
//                }
//                catch {
//                    
//                }
//                
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.hud.hide(true)
//                })
//                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
//            }
//        }
//        dataTask.resume()
//    }
    
    func inquireProperty(token: String, propertyId: String) -> Void {
        self.hud.show(true)
        let strURL = ("https://api.ditchthe.space/api/inquireproperty?token=\(token)&property_id=\(propertyId)")
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
//                    let detailCell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
//                    
//                    
//                    detailCell.btnRequestInfo.setTitle("Info requested", forState: .Normal)
//                    detailCell.btnRequestInfo.enabled = false
                    NSUserDefaults.standardUserDefaults().setObject("yes", forKey: propertyId)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                else {
                    let _utils = Utils()
                    _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
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

extension PropertyDetailViewController {
    
    func reportProperty(propertyId: String) -> Void {
        self.hud.show(true)
        
        var strURL = "https://api.ditchthe.space/api/createsupportticket?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&type=reported_listing&message=Reported%20listing%\(propertyId)"
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = "https://api.ditchthe.space/api/createsupportticket?token=\(token)&type=reported_listing&message=Reported%20listing%\(propertyId)"
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
                    let dict = json as? NSDictionary
                    if dict!["success"] as! Bool == true {
                        //                    let detailCell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
                        //
                        //
                        //                    detailCell.btnRequestInfo.setTitle("Info requested", forState: .Normal)
                        //                    detailCell.btnRequestInfo.enabled = false
//                        NSUserDefaults.standardUserDefaults().setObject("yes", forKey: propertyId)
//                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    else {
                        let _utils = Utils()
                        _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
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
    
    func hideProperty(token: String, propertyId: String) -> Void {
        self.hud.show(true)
        let strURL = ("https://api.ditchthe.space/api/hideproperty?token=\(token)&property_id=\(propertyId)")
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
                        //                    let detailCell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
                        //
                        //
                        //                    detailCell.btnRequestInfo.setTitle("Info requested", forState: .Normal)
                        //                    detailCell.btnRequestInfo.enabled = false
//                        NSUserDefaults.standardUserDefaults().setObject("yes", forKey: propertyId)
//                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    else {
                        let _utils = Utils()
                        _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
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
    
    func fillHighlights(property: NSDictionary) -> Void {
        if let bizCenter = property["build_amen_biz_center"] as? Int {
            if bizCenter == 1 {
                highlights += "\n\n\t Business Center"
            }
        }
        if let concierge = property["build_amen_concierge"] as? Int {
            if concierge == 1 {
                highlights += "\n\n\t Concierge"
            }
        }
        if let doorman = property["build_amen_doorman"] as? Int {
            if doorman == 1 {
                highlights += "\n\n\t Doorman"
            }
        }
        if let dryCleaning = property["build_amen_dry_cleaning"] as? Int {
            if dryCleaning == 1 {
                highlights += "\n\n\t Dry Cleaning"
            }
        }
        if let elevator = property["build_amen_elevator"] as? Int {
            if elevator == 1 {
                highlights += "\n\n\t Elevator"
            }
        }
        if let fitnessCenter = property["build_amen_fitness_center"] as? Int {
            if fitnessCenter == 1 {
                highlights += "\n\n\t Fitness Center"
            }
        }
        if let garage = property["build_amen_park_garage"] as? Int {
            if garage == 1 {
                highlights += "\n\n\t Garage"
            }
        }
        if let secureEntry = property["build_amen_secure_entry"] as? Int {
            if secureEntry == 1 {
                highlights += "\n\n\t Secure Entry"
            }
        }
        if let storage = property["build_amen_storage"] as? Int {
            if storage == 1 {
                highlights += "\n\n\t Storage"
            }
        }
        if let swimmingPool = property["build_amen_swim_pool"] as? Int {
            if swimmingPool == 1 {
                highlights += "\n\n\t Swim Pool"
            }
        }
    }
    
    func fillAmenities(property: NSDictionary) -> Void {
        //•
        if let ac = property["unit_amen_ac"] as? Int {
            if ac == 1 {
                amenities += "\n\n\t Air Conditioning"
            }
        }
        if let balcony = property["unit_amen_balcony"] as? Int {
            if balcony == 1 {
                amenities += "\n\n\t Balcony"
            }
        }
        if let carpet = property["unit_amen_carpet"] as? Int {
            if carpet == 1 {
                amenities += "\n\n\t Carpet"
            }
        }
        if let ceilingFan = property["unit_amen_ceiling_fan"] as? Int {
            if ceilingFan == 1 {
                amenities += "\n\n\t Ceiling Fan"
            }
        }
        if let deck = property["unit_amen_deck"] as? Int {
            if deck == 1 {
                amenities += "\n\n\t Deck"
            }
        }
        if let dishWasher = property["unit_amen_dishwasher"] as? Int {
            if dishWasher == 1 {
                amenities += "\n\n\t Dishwasher"
            }
        }
        if let fireplace = property["unit_amen_fireplace"] as? Int {
            if fireplace == 1 {
                amenities += "\n\n\t Fireplace"
            }
        }
        if let floorCarpet = property["unit_amen_floor_carpet"] as? Int {
            if floorCarpet == 1 {
                amenities += "\n\n\t Carpeted Floors"
            }
        }
        if let floorHardWood = property["unit_amen_floor_hard_wood"] as? Int {
            if floorHardWood == 1 {
                amenities += "\n\n\t Hardwood Floors"
            }
        }
        if let furnished = property["unit_amen_furnished"] as? Int {
            if furnished == 1 {
                amenities += "\n\n\t Furnished"
            }
        }
        if let laundry = property["unit_amen_laundry"] as? Int {
            if laundry == 1 {
                amenities += "\n\n\t Laundry"
            }
        }
        if let parkingReserved = property["unit_amen_parking_reserved"] as? Int {
            if parkingReserved == 1 {
                amenities += "\n\n\t Parking Reserved"
            }
        }
    }
    
    func getAddressFromCurrentLocation() -> Void {
        
        //self.hud.show(true)
        Location.reverseGeocodeLocation(AppDelegate.returnAppDelegate().currentLocation!, completion: { (placemark, error) in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                })
                return
            }
            
            if placemark?.name != nil && placemark?.administrativeArea != nil && placemark?.country != nil {
                let currentAddress = ("\(placemark!.name!), \(placemark!.administrativeArea!), \(placemark!.country!)")
                self.getDriveDuration(currentAddress, destinationAddress: self.dictProperty["address"] as! String)
//                self.getDriveDuration("18 West 33rd Street New York, NY 10001", destinationAddress: self.dictProperty["address"] as! String)
                
            }
        })
    }
    
    func getFormattedAddress(address: String) -> String {
        let addressToReturn = address.stringByReplacingOccurrencesOfString(", ", withString: ",").stringByReplacingOccurrencesOfString(" ", withString: "+")
        return addressToReturn
    }
    
    func getDriveDuration(currentAddress: String, destinationAddress: String) -> Void {
        let formattedCurrentAddress = getFormattedAddress(currentAddress)
        let formattedDesitationAddress = getFormattedAddress(destinationAddress)
        let strURL = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(formattedCurrentAddress)&destinations=\(formattedDesitationAddress)&key=\(googleMapsKey)"
        
//        let formattedURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.whitespaceCharacterSet())
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    
                    if let rows = json["rows"] as? NSArray {
                        if rows.count > 0 {
                            if let dictElements = rows[0] as? NSDictionary {
                                if let elements = dictElements["elements"] as? NSArray {
                                    if let geoElement = elements[0] as? NSDictionary {
                                        if let status = geoElement["status"] as? String {
                                            if status == "OK" {
                                                if let duration = geoElement["duration"] as? NSDictionary {
                                                    self.driveDuration = duration["text"] as? String
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), {
                                                        let cell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
                                                        if self.driveDuration != nil {
                                                            cell.lblDuration.text = self.driveDuration
//                                                            cell.lblDuration.text = "1 day 16 hours"

                                                        }
                                                        //self.tblDetail.reloadData()
                                                    })
                                                    
                                                }
                                            }
                                        }   
                                    }
                                }
                            }
                        }
                    }
                
                    print("worked")
                    
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


