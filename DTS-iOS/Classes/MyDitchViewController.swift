//
//  MyDitchViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 29/11/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD

class MyDitchViewController: UIViewController {
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var tblProperties: UITableView!
    var properties = NSMutableArray()
    var hud: MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        let revealController = revealViewController()
        //            revealController.panGestureRecognizer()
        revealController.panGestureRecognizer().enabled = false
        revealController.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)

        self.getMyProperties()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MyDitchViewController {
    func getMyProperties() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getproperty?page=1&token=\(token)&show_owned_only=1&show_active_only=0&show_reviewed_only=0")
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
                    self.properties = NSMutableArray()
                    let tmpProperties = tempData!["data"]!["data"] as! NSArray
                    self.properties.addObjectsFromArray(tmpProperties as [AnyObject])
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tblProperties.reloadData()
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
}

extension MyDitchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! MessagesTableViewCell
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        
        //cell.lblSubject.text = dictProperty["date_liked_formatted"] as? String
        cell.btnProperty.tag = indexPath.row
//        cell.btnProperty.addTarget(self, action: #selector(MessagesViewController.btnProperty_Tapped(_:)), forControlEvents: .TouchUpInside)
        
        cell.btnAction.tag = indexPath.row
//        cell.btnAction.addTarget(self, action: #selector(MessagesViewController.btnAction_Tapped(_:)), forControlEvents: .TouchUpInside)
        
        if let dictImage = dictProperty["img_url"] as? NSDictionary {
            if let imgURL = dictImage["sm"] as? String {
                SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                    cell.ivProperty.image = image
                })
            }
        }
        
        
        //cell.lblSubject.textColor = UIColor(hexString: "02ce37")
        
        
        //            cell.lblAddress.textAlignment = .Center
        let address1 = dictProperty["address1"] as! String
        
//        let city = dictProperty["city"] as! String
//        let state = dictProperty["state_or_province"] as! String
//        let zip = dictProperty["zip"] as! String
        
        cell.lblAddress.text = address1
        cell.lblStatus.text = dictProperty["status"] as? String
        //cell.lblCountry.text = "\(city), \(state) \(zip)"
        
        
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        if editingStyle == .Delete {
            
            let dictProperty = self.properties[indexPath.row] as! NSDictionary
            self.properties.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
                let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
                self.deleteMyProperty(token, propertyId: String(dictProperty["id"] as! Int), forRow: indexPath.row)
            }
            
        }
        tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as? PropertyDetailViewController
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        detailController!.propertyID = String(dictProperty["id"] as! Int)
        detailController?.dictProperty = dictProperty
        detailController?.isFromMainView = true
        
        self.navigationController?.pushViewController(detailController!, animated: true)
    }
    
}

extension MyDitchViewController {
    func deleteMyProperty(token: String, propertyId: String, forRow row: Int) -> Void {
        let strURL = ("https://api.ditchthe.space/api/deleteproperty?token=\(token)&id=\(propertyId)")
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
    
    func deleteProperty(propertyID: String) -> Void {
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
}
