//
//  ViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 03/04/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

import MBProgressHUD
import AVFoundation
import AVKit
import CoreLocation


class ViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, AVPlayerViewControllerDelegate, PropertyTableViewCellDelegate, SignupViewControllerDelegate {
    @IBOutlet weak var tblProperties: UITableView!
    
    @IBOutlet weak var btnGoBack: UIButton!
    @IBOutlet weak var btnLastSearch: UIButton!
    @IBOutlet weak var viewNearMe: UIView!
    @IBOutlet weak var btnNearMe: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var viewThirdOverlay: UIView!
    @IBOutlet weak var viewSecondOverlay: UIView!
    @IBOutlet weak var viewFirstOverlay: UIView!
    @IBOutlet weak var viewTopbarOverlay: UIView!
    @IBOutlet weak var tblViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cvBg: UICollectionView!
    
    
    @IBOutlet weak var lblHeaderTitle: UILabel!
    var mainData: NSDictionary?
    var properties = NSMutableArray()
    var hud: MBProgressHUD!
    var dictProperty: NSDictionary!
    var player: AVPlayer?
    var playerController: AVPlayerViewController?
    var bgImages: NSArray!
    var cachedImages: NSMutableArray!
    var refreshControl: UIRefreshControl!
    var reqType = 2
    var selectedRow: Int?
    var pageNumber = 1
    var originalURL = "https://api.ditchthe.space/api/getproperty?page=1"
    var nextURL: String?
    var mapController: PropertiesMapViewController!
    var searchController: SearchPropertiesViewController?
    var detailController: PropertyDetailViewController?
    var visitedProperties = [String]()
    var isFromSearch: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        self.properties = NSMutableArray()
        self.lblMessage.text = "No result found"
        AppDelegate.returnAppDelegate().presentedRow = -1
        self.tblProperties.superview?.clipsToBounds = false
        self.tblProperties.clipsToBounds = false
        
        self.view.backgroundColor = UIColor.blackColor()
        self.tblProperties.backgroundColor = UIColor.blackColor()
       
        
        if let savedRegion = NSUserDefaults.standardUserDefaults().objectForKey("selectedRegion") as? String {
            
            AppDelegate.returnAppDelegate().selectedSearchRegion = savedRegion
            if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
                if selectedRegion.characters.count > 0 {
                    let selectedRegionWithAbb = selectedRegion.stringByReplacingOccurrencesOfString(", United States", withString: "")
                    self.lblHeaderTitle.text = selectedRegionWithAbb
                }
            }
        }
        
        if let savedLat = NSUserDefaults.standardUserDefaults().objectForKey("selectedLat"), let savedLon = NSUserDefaults.standardUserDefaults().objectForKey("selectedLong") {
            AppDelegate.returnAppDelegate().selectedCoordinates = CLLocationCoordinate2DMake(savedLat as! Double, savedLon as! Double)
            //print(AppDelegate.returnAppDelegate().selectedCoordinates)
        }
        
        
        print(AppDelegate.returnAppDelegate().selectedCoordinates)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.updateListingWithCurrentLocation(_:)), name: "updateLocationFired", object: nil)
        
        if AppDelegate.returnAppDelegate().isAppLoading {
            AppDelegate.returnAppDelegate().isAppLoading = false
            //self.getSynchronousProperties(self.originalURL)
            //self.getProperties(self.originalURL)
            self.hud.show(true)
            self.loadPropertiesOnLaunch()   
        }
        else {
            self.properties = AppDelegate.returnAppDelegate().properties
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.videoStopped), name: "PlayerStopped", object: nil)
        self.btnAccount.hidden = true
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            self.btnAccount.hidden = false
            let revealController = revealViewController()
            revealController.panGestureRecognizer()
            revealController.tapGestureRecognizer()
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        }
        
        //        if AppDelegate.returnAppDelegate().showAnimation == true {
        //            AppDelegate.returnAppDelegate().showAnimation = false
        //            self.viewTopbarOverlay.hidden = false;
        //            self.viewFirstOverlay.hidden = false
        //            self.viewSecondOverlay.hidden = false
        //            self.viewThirdOverlay.hidden = false
        //        }
        //        else {
        //            self.viewTopbarOverlay.hidden = true
        //            self.viewFirstOverlay.hidden = true
        //            self.viewSecondOverlay.hidden = true
        //            self.viewThirdOverlay.hidden = true
        //        }
        
        
        
        self.lblMessage.hidden = true
        self.viewNearMe.hidden = true
        self.tblProperties.hidden = false
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tblProperties.addSubview(refreshControl)
        
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 19, left: 0, bottom: -12, right: 0)
    }
    
    func updateListingWithCurrentLocation(notification: NSNotification) -> Void {

        let currentLocation = notification.object as! CLLocation
        AppDelegate.returnAppDelegate().selectedCoordinates = currentLocation.coordinate
        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
            NSUserDefaults.standardUserDefaults().setDouble((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
            NSUserDefaults.standardUserDefaults().setDouble((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
            
            NSUserDefaults.standardUserDefaults().synchronize()

        }
    
        self.properties = NSMutableArray()
        self.getProperties(self.originalURL)
    }
    
    @IBAction func goBackButtonTapped(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(0, forKey: "searchType")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.lblHeaderTitle.text = "Near My Location"
        AppDelegate.returnAppDelegate().selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
            NSUserDefaults.standardUserDefaults().setDouble((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
            NSUserDefaults.standardUserDefaults().setDouble((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
            
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        self.properties = NSMutableArray()
        self.getProperties(self.originalURL)
    }
    @IBAction func lastSearchButtonTapped(sender: AnyObject) {
        if let arrCriteria = Utils.unarchiveSearch("propertySearch") {
            AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria.mutableCopy() as! NSMutableArray
            self.hud.show(true)
            self.createUserSearch()
        }
    }
    @IBAction func btnNearMe_Tapped(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(0, forKey: "searchType")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.lblHeaderTitle.text = "Near My Location"
        AppDelegate.returnAppDelegate().selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
            NSUserDefaults.standardUserDefaults().setDouble((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
            NSUserDefaults.standardUserDefaults().setDouble((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
            
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        self.properties = NSMutableArray()
        self.getProperties(self.originalURL)
    }
    
    func videoStopped() -> Void {
        UIView.animateWithDuration(0.3, animations: {
            self.viewTopbarOverlay.alpha = 0
            self.view.layoutIfNeeded()
        }) { (finished: Bool) in
            self.viewTopbarOverlay.hidden = true
            
            UIView.animateWithDuration(0.3, animations: {
                self.viewFirstOverlay.alpha = 0
                self.view.layoutIfNeeded()
            }) { (finished: Bool) in
                self.viewFirstOverlay.hidden = true
                UIView.animateWithDuration(0.3, animations: {
                    self.viewSecondOverlay.alpha = 0
                    self.view.layoutIfNeeded()
                }) { (finished: Bool) in
                    self.viewSecondOverlay.hidden = true
                    UIView.animateWithDuration(0.3, animations: {
                        self.viewThirdOverlay.alpha = 0
                        self.view.layoutIfNeeded()
                    }) { (finished: Bool) in
                        self.viewThirdOverlay.hidden = true
                    }
                }
            }
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.tabBarController?.tabBar.hidden = true
        
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        //        self.properties = NSMutableArray()
        self.doSearch()
        
    }
    
    func loadPropertiesOnLaunch() -> Void {
        if NSUserDefaults.standardUserDefaults().integerForKey("searchType") == 0 {
            self.getProperties(self.originalURL)
        }
        else if NSUserDefaults.standardUserDefaults().integerForKey("searchType") == 1 {
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
            }
            self.createUserSearch()
        }
        else if NSUserDefaults.standardUserDefaults().integerForKey("searchType") == 2 {
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
            }
            self.createAgentSearch()
        }
        
    }
    
    func doSearch() -> Void {
        if NSUserDefaults.standardUserDefaults().integerForKey("searchType") == 0 {
            self.getPropertiesForRefresh(originalURL)
        }
        else if NSUserDefaults.standardUserDefaults().integerForKey("searchType") == 1 {
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
            }
            self.createUserSearch()
        }
        else if NSUserDefaults.standardUserDefaults().integerForKey("searchType") == 2 {
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
            }
            self.createAgentSearch()
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        showHideBottomBar()
    }
    @IBAction func headerNearMeButtonTapped(sender: AnyObject) {
        self.getProperties(self.originalURL)
    }
    
    @IBAction func btnCreateListing_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty = NSMutableDictionary()
        AppDelegate.returnAppDelegate().newlyCreatedPropertyId = 0
        AppDelegate.returnAppDelegate().isNewProperty = true
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclclassVC") as! UCLClassViewController
        controller.listType = "class"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUserSearch() -> Void {
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                let selectedRegionWithAbb = selectedRegion.stringByReplacingOccurrencesOfString(", United States", withString: "")
                self.lblHeaderTitle.text = selectedRegionWithAbb
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
    
        print(body)
        
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
                        /*dispatch_async(dispatch_get_main_queue(), {
                            self.hud.hide(true)
                        })*/
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
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hud.hide(true)
                            })
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
    
    func createAgentSearch() -> Void {
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                let selectedRegionWithAbb = selectedRegion.stringByReplacingOccurrencesOfString(", United States", withString: "")
                self.lblHeaderTitle.text = selectedRegionWithAbb
            }
        }
        
        var strURL = "https://api.ditchthe.space/api/createusersearch?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&create_search_agent=1"
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/createusersearch?token=\(token)&create_search_agent=1")
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
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hud.hide(true)
                            })
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
                        self.refreshControl.endRefreshing()
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
                        self.refreshControl.endRefreshing()
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
                        dispatch_async(dispatch_get_main_queue(), {
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
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
                    
                    //var i = 0
                    
                    AppDelegate.returnAppDelegate().properties = self.properties
                    for dict in self.properties {
                        let imagesTobeCached = dict["imgs"] as! NSArray
                        
                        let dictImg = imagesTobeCached[0] as! NSDictionary
                        let strImgURL = dictImg["img_url"]!["md"] as! String
                        let imgURL = NSURL(string: strImgURL)
                        
                        SDWebImageManager.sharedManager().downloadImageWithURL(imgURL!, options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                            if error == nil {
                                
                            }
                        })
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.refreshControl.endRefreshing()
                        self.hud.hide(true)
                        if self.properties.count == 0 {
                            self.tblProperties.hidden = true
                            self.lblMessage.hidden = false
                            self.viewNearMe.hidden = false
                        }
                        else {
                            self.tblProperties.hidden = false
                            self.lblMessage.hidden = true
                            self.viewNearMe.hidden = true
                        }
                        self.tblProperties.reloadData()
                    })
                
                }
                catch {
                    
                }
                
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                })
                
            }
        }
        dataTask.resume()
    }
    
    func getPropertiesForRefresh(strURL: String) -> Void {
        
        
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
                    self.properties = (self.mainData!["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    
                    _ = 0
                    for dict in self.properties {
                        let imagesTobeCached = dict["imgs"] as! NSArray
                        
                        let dictImg = imagesTobeCached[0] as! NSDictionary
                        let strImgURL = dictImg["img_url"]!["md"] as! String
                        let imgURL = NSURL(string: strImgURL)
                        
                        SDWebImageManager.sharedManager().downloadImageWithURL(imgURL, options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                            
                        })
                        
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tblProperties.reloadData()
                        self.tblProperties.hidden = false
                        self.refreshControl.endRefreshing()
                    })
                    
                }
                catch {
                    
                }
                
            }
            else {
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }
        dataTask.resume()
    }
    
    func getProperties(strURL: String) -> Void {
        
        self.isFromSearch = false
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
                    self.properties.addObjectsFromArray(self.mainData!["data"] as! NSArray as [AnyObject])
                    dispatch_async(dispatch_get_main_queue(), {
                        if self.properties.count == 0 {
                            self.tblProperties.hidden = true
                            self.lblMessage.hidden = false
                            self.viewNearMe.hidden = false
                        }
                        else {
                            self.tblProperties.hidden = false
                            self.lblMessage.hidden = true
                            self.viewNearMe.hidden = true
                            self.tblProperties.reloadData()
                        }
                    })
                    AppDelegate.returnAppDelegate().properties = self.properties
                    //var i = 0
                    for dict in self.properties {
                        let imagesTobeCached = dict["imgs"] as! NSArray
                        
                        let dictImg = imagesTobeCached[0] as! NSDictionary
                        let strImgURL = dictImg["img_url"]!["md"] as! String
                        let imgURL = NSURL(string: strImgURL)
                        
                        SDWebImageManager.sharedManager().downloadImageWithURL(imgURL, options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
//                            if error == nil {
//                                AppDelegate.returnAppDelegate().cachedImages.setObject(image, forKey: strImgURL)
//                                i += 1
//                                
//                                dispatch_async(dispatch_get_main_queue(), {
//                                    if i > 2 {
//                                        if self.properties.count == 0 {
//                                            self.tblProperties.hidden = true
//                                            self.lblMessage.hidden = false
//                                            self.btnNearMe.hidden = false
//                                        }
//                                        else {
//                                            self.tblProperties.hidden = false
//                                            self.lblMessage.hidden = true
//                                            self.btnNearMe.hidden = true
//                                        }
//                                        self.tblProperties.reloadData()
//                                        self.tblProperties.hidden = false
//                                        self.refreshControl.endRefreshing()
//                                    }
//                                    if i == self.properties.count {
//                                        if self.properties.count == 0 {
//                                            self.tblProperties.hidden = true
//                                            self.lblMessage.hidden = false
//                                            self.btnNearMe.hidden = false
//                                        }
//                                        else {
//                                            self.tblProperties.hidden = false
//                                            self.lblMessage.hidden = true
//                                            self.btnNearMe.hidden = true
//                                        }
//                                        self.tblProperties.reloadData()
//                                        self.tblProperties.hidden = false
//                                        self.refreshControl.endRefreshing()
//                                    }
//                                })
//                        
//                            }
                        })
                        
                        
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
    
    
    
    /*func getProperties(strURL: String) -> Void {
     
     self.isFromSearch = false
     self.hud.show(true)
     var strURL = "\(strURL)&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&show_owned_only=0&show_active_only=1&latitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)&longitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)"
     
     
     
     if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
     let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
     strURL = ("\(strURL)&token=\(token)&show_owned_only=0&show_active_only=1&latitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)&longitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)")
     }
     
     
     let url = NSURL(string: <#T##String#>)
     let request = NSURLRequest(URL: <#T##NSURL#>)
     
     self.alamoFireManager!.request(.GET, strURL).responseJSON { (Response) in
     self.hud.hide(true)
     print("Request: \n \(Response.request!)")
     if Response.result.isSuccess {
     print("\n Response: \n \(Response.response!)")
     let tempData = Response.result.value as? NSDictionary
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
     self.properties.addObjectsFromArray(self.mainData!["data"] as! NSArray as [AnyObject])
     if self.properties.count == 0 {
     self.tblProperties.hidden = true
     self.lblMessage.hidden = false
     self.btnNearMe.hidden = false
     }
     var i = 0
     for dict in self.properties {
     let imagesTobeCached = dict["imgs"] as! NSArray
     
     let dictImg = imagesTobeCached[0] as! NSDictionary
     let strImgURL = dictImg["img_url"]!["md"] as! String
     let imgURL = NSURL(string: strImgURL)
     
     SDWebImageManager.sharedManager().downloadImageWithURL(imgURL, options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
     if error == nil {
     AppDelegate.returnAppDelegate().cachedImages.setObject(image, forKey: strImgURL)
     i += 1
     if i > 2 {
     if self.properties.count == 0 {
     self.tblProperties.hidden = true
     self.lblMessage.hidden = false
     self.btnNearMe.hidden = false
     }
     else {
     self.tblProperties.hidden = false
     self.lblMessage.hidden = true
     self.btnNearMe.hidden = true
     }
     self.tblProperties.reloadData()
     self.tblProperties.hidden = false
     self.refreshControl.endRefreshing()
     }
     if i == self.properties.count {
     if self.properties.count == 0 {
     self.tblProperties.hidden = true
     self.lblMessage.hidden = false
     self.btnNearMe.hidden = false
     }
     else {
     self.tblProperties.hidden = false
     self.lblMessage.hidden = true
     self.btnNearMe.hidden = true
     }
     self.tblProperties.reloadData()
     self.tblProperties.hidden = false
     self.refreshControl.endRefreshing()
     }
     }
     })
     
     AppDelegate.returnAppDelegate().properties = self.properties
     
     self.performSelector(#selector(ViewController.cacheImages(_:)), withObject: imagesTobeCached, afterDelay: 0.1)
     
     }
     
     }
     else {
     print("\n Response: \n \(Response)")
     let tempData = Response.result.value as? NSDictionary
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
     let _utils = Utils()
     self.hud.hide(true)
     
     _utils.showOKAlert("Error", message: (Response.result.error?.localizedDescription)!, controller: self, isActionRequired: false)
     return
     
     }
     }
     }*/
    
    func getPropertiesInBackground(strURL: String) -> Void {
        //self.hud.show(true)
        self.isFromSearch = false
        
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
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let tempData = json as? NSDictionary
                    self.nextURL = tempData!["next_page_url"] as? String
                    self.mainData = tempData!["data"] as? NSDictionary
                    self.properties.addObjectsFromArray(self.mainData!["data"] as! NSArray as [AnyObject])
                    
                    AppDelegate.returnAppDelegate().properties = self.properties
                    
                    for dict in self.properties {
                        let imagesTobeCached = dict["imgs"] as! NSArray
                        
                        self.performSelector(#selector(ViewController.cacheImages(_:)), withObject: imagesTobeCached, afterDelay: 0.1)
                        
                    }
                }
                catch {
                    
                }
            }
            else {
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
            }
        }
        dataTask.resume()
    }
    
    func getPropertyForLike(propertyID: String, selectedIndex: Int) -> Void {
        var strURL = "https://api.ditchthe.space/api/getproperty?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE&property_id=\(propertyID)&show_owned_only=0&show_active_only=1"
        
        
        
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
    
    func cacheImages(images: NSArray) -> Void {
        for dictImg in images {
            
            let strImgURL = dictImg["img_url"]!!["md"] as! String
            let imgURL = NSURL(string: strImgURL)
            
            SDWebImageManager.sharedManager().downloadImageWithURL(imgURL, options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                if error == nil {
                    AppDelegate.returnAppDelegate().cachedImages.setObject(image, forKey: strImgURL)
                }
            })
        }
        
    }
    
    // Mark: - UITableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.properties.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //cell.hidden = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! PropertyTableViewCell
        cell.delegate = self
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        
        self.bgImages = dictProperty["imgs"] as! NSArray
        
        cell.tag = indexPath.row
        cell.loadImages(self.bgImages)
        
        cell.imgViewNewTop.hidden = true
        
        let x = cell.cvBG.contentOffset.x
        let w = cell.cvBG.bounds.size.width
        let currentPage = Int(ceil(x/w))
        cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
        
        
        let strCreatedDate = dictProperty["created_at"] as! String
        let daysBetween = Utils.calculateDaysBetweenDates("", createdDate: strCreatedDate)
        
        print(daysBetween)
        if daysBetween < 2 {
            cell.imgViewNewTop.hidden = false
        }
        
//        if indexPath.row % 2 == 0 {
//            cell.imgViewNew.hidden = false
//         }
        
        
        
        
//        if indexPath.row > self.properties.count - 3 {
//            cell.imgViewNew.hidden = false
//        }
        
        
        //cell.lblCounter.text = ("1/\(self.bgImages.count)")
        
        //        let price = dictProperty["price"]!.componentsSeparatedByString(".")[0]
        let priceNumber = NSNumber.init(integer: dictProperty["price"] as! Int)
        let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
        cell.lblPrice.text = ("$\(price)")
        cell.lblPrice.textColor = UIColor(hexString: "02ce37")
        cell.lblAddress.text = (dictProperty["address1"] as? String)?.capitalizedString
        cell.viewCounter.layer.cornerRadius = 6
        cell.viewCounter.clipsToBounds = true
        
        
        
        cell.ivStamp.hidden = true

        if Bool(dictProperty["inquired"] as! Int) == true {
            cell.ivStamp.hidden = false
        }
        
        let bath = String(dictProperty["bath"] as! Int)
        let bed = String(dictProperty["bed"] as! Int)
        
        cell.lblBathrooms.text = bath
        cell.lblBedrooms.text = bed
        
        cell.btnLike.addTarget(self, action: #selector(ViewController.btnLike_Tapped(_:)), forControlEvents: .TouchUpInside)
        cell.btnLike.selected = false
        let isLiked = dictProperty["liked"] as! Bool
        if isLiked == true {
            cell.btnLike.selected = true
        }
        
        //cell.cvBG
        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        
        cell.superview?.superview?.clipsToBounds = false
        cell.superview?.clipsToBounds = false
        cell.backgroundView?.clipsToBounds = false
        cell.btnLike.tag = indexPath.row
        //        if indexPath.row == 0 {
        ////            cell.cvBG.hidden = true
        //            cell.sendSubviewToBack(cell.cvBG)
        //        }
//        cell.cvBG.hidden = true
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "listingToDetail" {
            let controller = segue.destinationViewController as! PropertyDetailViewController
            controller.propertyID = String(self.dictProperty["id"] as! Int)
            controller.dictProperty = self.dictProperty
            controller.isFromMainView = true
        }
        else if (segue.identifier == "listingToMap") {
            let controller = segue.destinationViewController as! PropertiesMapViewController
            controller.properties = self.properties
        }
        else if segue.identifier == "propertiesToSignup" {
            let controller = segue.destinationViewController as! SignUpViewController
            controller.propertyId = String(dictProperty["id"] as! Int)
            controller.reqType = reqType
            controller.delegate = self
        }
        else if segue.identifier == "propertiesVCToSearchProperties" {
            let controller = segue.destinationViewController as! SearchPropertiesViewController
            controller.delegate = self
        }
    }
    
    private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource("dts-splash", ofType:"mp4") else {
            throw AppError.InvalidResource("dts-splash", "mp4")
        }
        player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        playerController = AVPlayerViewController()
        playerController!.player = player
        self.addChildViewController(playerController!)
        playerController!.view.frame = self.view.bounds
        playerController!.showsPlaybackControls = false
        self.view.addSubview(playerController!.view)
        player!.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        playerController?.view.removeFromSuperview()
        playerController?.removeFromParentViewController()
        
        if AppDelegate.returnAppDelegate().showAnimation == true {
            AppDelegate.returnAppDelegate().showAnimation = false
            UIView.animateWithDuration(0.3, animations: {
                self.viewTopbarOverlay.alpha = 0
                self.view.layoutIfNeeded()
            }) { (finished: Bool) in
                self.viewTopbarOverlay.hidden = true
                
                UIView.animateWithDuration(0.3, animations: {
                    self.viewFirstOverlay.alpha = 0
                    self.view.layoutIfNeeded()
                }) { (finished: Bool) in
                    self.viewFirstOverlay.hidden = true
                    UIView.animateWithDuration(0.3, animations: {
                        self.viewSecondOverlay.alpha = 0
                        self.view.layoutIfNeeded()
                    }) { (finished: Bool) in
                        self.viewSecondOverlay.hidden = true
                        UIView.animateWithDuration(0.3, animations: {
                            self.viewThirdOverlay.alpha = 0
                            self.view.layoutIfNeeded()
                        }) { (finished: Bool) in
                            self.viewThirdOverlay.hidden = true
                        }
                    }
                }
                
            }
        }
    }
    
    func didSelected(tag: NSInteger) {
        self.dictProperty = self.properties[tag] as! NSDictionary
        
        
        
        //pDetailVC
        
        /*if self.detailController == nil {
         self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as? PropertyDetailViewController
         
         detailController!.propertyID = String(self.dictProperty["id"] as! Int)
         detailController?.dictProperty = self.dictProperty
         detailController?.isFromMainView = true
         self.visitedProperties.append((detailController?.propertyID)!)
         }
         else {
         let propertyID = String(self.dictProperty["id"] as! Int)
         detailController!.propertyID = propertyID
         if !self.visitedProperties.contains(propertyID) {
         self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as? PropertyDetailViewController
         detailController?.dictProperty = self.dictProperty
         detailController?.isFromMainView = true
         detailController!.propertyID = String(self.dictProperty["id"] as! Int)
         self.visitedProperties.append((detailController?.propertyID)!)
         }
         }*/
        
        AppDelegate.returnAppDelegate().isNewProperty = nil
        
        self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as? PropertyDetailViewController
        
        detailController!.propertyID = String(self.dictProperty["id"] as! Int)
        detailController?.dictProperty = self.dictProperty
        detailController?.isFromMainView = true
        self.visitedProperties.append((detailController?.propertyID)!)
        
        self.navigationController?.pushViewController(self.detailController!, animated: true)
        
    }
    
    
    @IBAction func btnViewMap_Tapped(sender: AnyObject) {
        /**if mapController == nil {
            mapController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mapVC") as! PropertiesMapViewController
            mapController.properties = self.properties
            mapController.delegate = self
        }**/
        
        mapController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mapVC") as! PropertiesMapViewController
        mapController.properties = self.properties
        mapController.delegate = self
        
        UIView.transitionWithView((self.navigationController?.view)!, duration: 0.5, options: .TransitionFlipFromRight, animations: {
            self.navigationController?.pushViewController(self.mapController, animated: false)
        }) { (completed: Bool) in
            
        }
        
    }
    
    @IBAction func btnLike_Tapped(sender: AnyObject) {
        let btn = sender as! UIButton
        self.dictProperty = self.properties[btn.tag] as! NSDictionary
        self.selectedRow = btn.tag
        if NSUserDefaults.standardUserDefaults().objectForKey("token") == nil {
            reqType = 2
            self.performSegueWithIdentifier("propertiesToSignup", sender: self)
        }
        else {
            let propertyCell = self.tblProperties.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRow!, inSection: 0)) as! PropertyTableViewCell
            
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
                        let propertyCell = self.tblProperties.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRow!, inSection: 0)) as! PropertyTableViewCell
                        propertyCell.btnLike.selected = false
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: dict!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                }
                catch {
                    
                }
            }
            else {
                
                
                let propertyCell = self.tblProperties.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRow!, inSection: 0)) as! PropertyTableViewCell
                propertyCell.btnLike.selected = false
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
            }
        }
        dataTask.resume()
    }
    
    func didSignedUpSuccessfully() {
        showHideBottomBar()
        let propertyCell = self.tblProperties.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRow!, inSection: 0)) as! PropertyTableViewCell
        propertyCell.btnLike.selected = true
        self.properties = NSMutableArray()
        self.getProperties(self.originalURL)
        
    }
    
    func showHideBottomBar() -> Void {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let endScrolling = (scrollView.contentOffset.y + scrollView.frame.size.height)
        if endScrolling >= scrollView.contentSize.height {
            if nextURL != nil {
                self.hud.show(true)
                self.getProperties(nextURL!)
            }
        }
    }
}

enum AppError : ErrorType {
    case InvalidResource(String, String)
}

extension ViewController: SearchPropertiesDelegate {
    func didPressedDoneButton(isAgent: Bool) {
        if isAgent == false {
            self.hud.show(true)
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "searchType")
            self.createUserSearch()
            
        }
        else {
            NSUserDefaults.standardUserDefaults().setInteger(2, forKey: "searchType")
            self.createAgentSearch()
        }
    }
}

extension ViewController: MapPropertiesDelegate {
    func didListingButtonTappe(properties: NSMutableArray) {
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                let selectedRegionWithAbb = selectedRegion.stringByReplacingOccurrencesOfString(", United States", withString: "")
                self.lblHeaderTitle.text = selectedRegionWithAbb
            }
        }
        self.properties = properties
        dispatch_async(dispatch_get_main_queue(), {
            if self.properties.count == 0 {
                self.tblProperties.hidden = true
                self.lblMessage.hidden = false
                self.viewNearMe.hidden = false
            }
            else {
                self.tblProperties.hidden = false
                self.lblMessage.hidden = true
                self.viewNearMe.hidden = true
            }
            self.tblProperties.reloadData()
        })
    }
}






