//
//  FollowUpViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 21/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

import MBProgressHUD

class FollowUpViewController: BaseViewController {

    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnProperty: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tblFollowup: UITableView!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var ivProperty: UIImageView!
    var dictSelectedMessage: NSDictionary!
    var dictProperty: NSDictionary!
    var hud: MBProgressHUD!
    var isInquired: Bool!
    var custView: CustomView!
    var allMessages = NSMutableArray()
    var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.returnAppDelegate().isBack = true
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        // Do any additional setup after loading the view.
        self.populateFields()
        self.btnAccount.hidden = true
//        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
//            self.btnAccount.hidden = false
//        }
        allMessages.addObject(dictSelectedMessage)
    
        self.populateMessages()
        self.custView = CustomView(frame: UIScreen.mainScreen().bounds)
        self.custView.backgroundColor = UIColor.clearColor()
        self.custView.becomeFirstResponder()
        self.custView.keyboardBarDelegate = self
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(FollowUpViewController.didTouchView))
        
        if dictSelectedMessage["type"] as! String != "inquire" {
            self.view.addSubview(self.custView)
            self.view.addGestureRecognizer(tapGestureRecogniser)
        }
        
        self.tblFollowup.estimatedRowHeight = 80
        self.tblFollowup.rowHeight = UITableViewAutomaticDimension
        
        self.view.bringSubviewToFront(self.headerView)
        self.view.bringSubviewToFront(self.btnProperty)
        self.view.bringSubviewToFront(self.tblFollowup)
        self.view.bringSubviewToFront(self.hud)
        let scrollIndexPath = NSIndexPath(forRow: self.allMessages.count - 1, inSection: 0)
        self.tblFollowup.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition: .Bottom, animated: false)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(FollowUpViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tblFollowup.addSubview(refreshControl)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(FollowUpViewController.sendBack))
        swipeGesture.direction = .Right
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    func sendBack() -> Void {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnAccount_Tapped(sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func populateMessages() -> Void {
        if dictSelectedMessage["children"]?.count > 0 {
            let childrenMessages = self.dictSelectedMessage["children"] as! NSArray
            for dict in childrenMessages {
                let dictChildMsg = dict as! NSDictionary
                allMessages.addObject(dictChildMsg)
                
                let grandChildrenMessags = dictChildMsg["children"] as! NSArray
                
                if grandChildrenMessags.count > 0 {
                    for dictG in grandChildrenMessags {
                        let dictGrandChildMsg = dictG as! NSDictionary
                        allMessages.addObject(dictGrandChildMsg)
                    }
                }
            }
        }
    }
    
    func refresh(sender:AnyObject) {
        self.getMessage()
    }
    
    func didTouchView() -> Void {
        self.custView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessage() -> Void {
        var strURL = ""
        
        let msgId = dictSelectedMessage["id"] as! Int
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getmsg?token=\(token)&msg_id=\(msgId)&type=thread&paginated=0&page=1")
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
                
                let properties = tempData!["data"]!["thread"] as! NSArray
                let msgs = properties[0]["msgs"] as! NSArray
                self.dictSelectedMessage = msgs[0] as! NSDictionary
                self.allMessages = NSMutableArray()
                self.allMessages.addObject(self.dictSelectedMessage)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.populateMessages()
                        self.tblFollowup.reloadData()
                        let scrollIndexPath = NSIndexPath(forRow: self.allMessages.count - 1, inSection: 0)
                        self.tblFollowup.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition: .Bottom, animated: false)
                        self.refreshControl.endRefreshing()
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
    
    func SendMessage(text: String) -> Void {
        var token = ""
        let strURL = "https://api.ditchthe.space/api/sendmsg"
        let recipientID = dictSelectedMessage["sender_id"] as! Double
                let messageContent = text
        let messageID = dictSelectedMessage["id"] as! Double
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        }
        
        let paramDict = ["token": token, "recipient_id": recipientID, "message": messageContent, "parent_msg_id": messageID]
        self.hud.show(true)
        
        do {
            let jsonParamsData = try NSJSONSerialization.dataWithJSONObject(paramDict, options: [])
            
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
                    let isSuccess = Bool(tempData!["success"] as! Int)
                    if isSuccess == false {
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    let dictTemp = ["recipient_id": 1, "content": text, "updated_at_formatted": "1 seconds ago"]
                    self.allMessages.addObject(dictTemp)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tblFollowup.reloadData()
                            let scrollIndexPath = NSIndexPath(forRow: self.allMessages.count - 1, inSection: 0)
                            self.tblFollowup.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition: .Bottom, animated: false)
                        })
                    
                    //                self.navigationController?.popViewControllerAnimated(true)
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
    
    @IBAction func btnProperty_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func populateFields() -> Void {
//        self.lblSubject.text = dictSelectedMessage["subject"] as? String
        
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
        
        let imgURL = dictProperty["img_url"]!["sm"] as! String
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
            self.ivProperty.image = image
        })
    }
}


extension FollowUpViewController: KeyboardBarDelegate {
    func keyboardBar(keyboardBar: KeyboardBar!, sendText text: String!) {
        self.custView.becomeFirstResponder()
        self.SendMessage(text)
        keyboardBar.textView.text = ""
    }
}

extension FollowUpViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("followCell", forIndexPath: indexPath) as! FollowupTableViewCell
        let dictMessage = self.allMessages[indexPath.row] as! NSDictionary
        if let dictRecipient = dictMessage["recipient"] as? NSDictionary {
            if let cidRecipient = dictRecipient["cid"] as? String {
                if let userCid = NSUserDefaults.standardUserDefaults().objectForKey("cid") as? String {
                    if cidRecipient == userCid {
                        cell.lblTitle.text = "BROKER SAID"
                        cell.lblTitle.textColor = UIColor(hexString: "02ce37")
                    }
                    else {
                        cell.lblTitle.text = "YOU SAID"
                        cell.lblTitle.textColor = UIColor(hexString: "ff0500")
                    }
                }
            }
        }
//        cell.lblTitle.text = "BROKER SAID"
//        cell.lblTitle.textColor = UIColor(hexString: "02ce37")
//        if dictMessage["recipient_id"] as! Int == 1 {
//            cell.lblTitle.text = "YOU SAID"
//            cell.lblTitle.textColor = UIColor(hexString: "ff0500")
//        }
        cell.lblDuration.text = dictMessage["updated_at_formatted"] as? String
        cell.lblContent.text = dictMessage["content"] as? String
        cell.selectionStyle = .None
        return cell
    }
}
