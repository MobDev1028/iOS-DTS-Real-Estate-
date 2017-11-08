//
//  FavoritesViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 19/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit


import MBProgressHUD

class FavoritesViewController: BaseViewController {

    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var tblFavorites: UITableView!
    var isCurrentlyEditing: Bool = false
    var properties = NSMutableArray()
    
    var hud: MBProgressHUD!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        self.btnAccount.hidden = true
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            self.btnAccount.hidden = false
            let revealController = revealViewController()
//            revealController.panGestureRecognizer()
            revealController.tapGestureRecognizer()
            
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.getFavoriteProperties()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func unLikeProperty(token: String, propertyId: String, forRow row: Int) -> Void {
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
//                    self.properties.removeObjectAtIndex(row)
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
    
    func getFavoriteProperties() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getuserfav?token=\(token)&paginated=0&page=0")
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.hud.show(true)
        })
        
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
                let dictFavs = tempData!["data"]!["favs"] as! NSDictionary
                let dictHides = tempData!["data"]!["hides"] as! NSDictionary
                self.properties = NSMutableArray()
                let tmpProperties = dictFavs["data"] as! NSArray
                let hiddenProperties = dictHides["data"] as! NSArray
                self.properties.addObjectsFromArray(tmpProperties as [AnyObject])
                self.properties.addObjectsFromArray(hiddenProperties as [AnyObject])
                    dispatch_async(dispatch_get_main_queue(), {
                       self.tblFavorites.reloadData()
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
    
    @IBAction func btnProperty_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let btn = sender as! UIButton
        let dictProperty = self.properties[btn.tag] as! NSDictionary
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        controller.dictProperty = dictProperty
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnAction_Tapped(sender: AnyObject) {
        if isCurrentlyEditing {
            return
        }
        let btn = sender as! UIButton
        let dictProperty = self.properties[btn.tag] as! NSDictionary
        var address = dictProperty["address"] as! String
        address =  address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: ("https://maps.apple.com/?address=\(address)"))
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func btnAccount_Tapped(sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath)
    {
        isCurrentlyEditing = true
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath?)
    {
        isCurrentlyEditing = false
    }  
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! MessagesTableViewCell
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        
        cell.lblSubject.text = dictProperty["date_liked_formatted"] as? String
        cell.btnProperty.tag = indexPath.row
        cell.btnProperty.addTarget(self, action: #selector(MessagesViewController.btnProperty_Tapped(_:)), forControlEvents: .TouchUpInside)
        
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(MessagesViewController.btnAction_Tapped(_:)), forControlEvents: .TouchUpInside)
        
        let imgURL = dictProperty["img_url"]!["sm"] as! String
        
        cell.lblSubject.textColor = UIColor(hexString: "02ce37")
        
        
        //            cell.lblAddress.textAlignment = .Center
        let address1 = dictProperty["address1"] as! String
        let city = dictProperty["city"] as! String
        let state = dictProperty["state_or_province"] as! String
        let zip = dictProperty["zip"] as! String
        
        cell.lblAddress.text = address1
        cell.lblCountry.text = "\(city), \(state) \(zip)"
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
            cell.ivProperty.image = image
        })
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clearColor()
        let hidden = Bool(dictProperty["hidden"] as! Int)
        if hidden {
            cell.backgroundColor = UIColor.redColor()
        }
        
        return cell
    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        let (parent, isParentCell, actualPosition) = self.findParent(indexPath.row)
//        if isParentCell {
//            return false
//        }
//        return true
//    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let deletRowAction = UITableViewRowAction(style: .Destructive, title: "UNFAV") { (action, indexpath) in
            let dictProperty = self.properties[indexPath.row] as! NSDictionary
            self.properties.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
                let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
                self.unLikeProperty(token, propertyId: String(dictProperty["id"] as! Int), forRow: indexPath.row)
            }
        }
        
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        let hidden = Bool(dictProperty["hidden"] as! Int)
        if hidden {
            let hideRowAction = UITableViewRowAction(style: .Default, title: "UNHIDE") { (action, indexpath) in
                if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
                    let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
                    self.hideProperty(token, propertyId: String(dictProperty["id"] as! Int))
                }
            }
            
            hideRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
            
            return [hideRowAction]
        }
        else {
            let hideRowAction = UITableViewRowAction(style: .Default, title: "HIDE") { (action, indexpath) in
                if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
                    let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
                    self.hideProperty(token, propertyId: String(dictProperty["id"] as! Int))
                }
            }
            
            hideRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
            
            return [deletRowAction, hideRowAction]
        }
        
        
        
        
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "UNFAV"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.tblFavorites.beginUpdates()
        if editingStyle == .Delete {
            
            let dictProperty = self.properties[indexPath.row] as! NSDictionary
            self.properties.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
                let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
                self.unLikeProperty(token, propertyId: String(dictProperty["id"] as! Int), forRow: indexPath.row)
            }
            
        }
        self.tblFavorites.endUpdates()
    }
    
}

extension FavoritesViewController {
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
                        self.getFavoriteProperties()
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
}

