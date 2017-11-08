//
//  SignatureViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 31/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

import MBProgressHUD

class SignatureViewController: BaseViewController {

    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var ivProperty: UIImageView!
    @IBOutlet weak var drawSignatureView: YPDrawSignatureView!
    @IBOutlet weak var viewSignatureContainer: UIView!
    var dictSelectedMessage: NSDictionary!
    var signedResponseDict: NSDictionary!
    var documentPath: NSURL!
    var hud: MBProgressHUD!
    var dictProperty: NSDictionary!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        self.viewSignatureContainer.layer.cornerRadius = 6
        self.viewSignatureContainer.layer.borderColor = UIColor.grayColor().CGColor
        self.viewSignatureContainer.layer.borderWidth = 1
        self.viewSignatureContainer.clipsToBounds = true
        self.populateFields()
        self.drawSignatureView.strokeColor = UIColor.redColor()
        self.btnAccount.hidden = true
//        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
//            self.btnAccount.hidden = false
//        }
    }
    
    @IBAction func btnAccount_Tapped(sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
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
        
        let imgURL = dictProperty["img_url"]!["sm"] as! String
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
            self.ivProperty.image = image
        })
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func writeImageToPath(fileName: String, data: NSData) -> Void {
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(fileName)
            print(path)
            
            do {
                try data.writeToURL(path!, options: .DataWritingAtomic)
            }
            catch {
            }
            
            
        }
    }
    
    func sendSignature(signImage: UIImage) -> Void {
        
        let imageData:NSData = UIImagePNGRepresentation(signImage)!
        //self.writeImageToPath("temp.png", data: imageData)
        let strBase64:String = imageData.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
        //let strBase64 = imageData.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
        
        var token = ""
        let strURL = "https://api.ditchthe.space/api/signdoc"
        //let recipientID = dictSelectedMessage["sender_id"] as! Double
        let docTemplateID = dictSelectedMessage["doc_template_id"] as! Double
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        }
        

        var addr = getWiFiAddress()
        if addr == nil {
            addr = "119.152.216.151"
        }
        
        let paramDict = ["token": token, "doc_template_id": docTemplateID, "signature": strBase64, "ip": addr!]
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
                        dispatch_async(dispatch_get_main_queue(), {
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
            
                        return
                    }
                        
                        self.signedResponseDict = tempData!["data"] as! NSDictionary
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSegueWithIdentifier("signToDoc", sender: self)
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
        catch {
        
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signToDoc" {
            let controller = segue.destinationViewController as! DocMessageViewController
            controller.dictSelectedMessage = self.dictSelectedMessage
            controller.dictSignedResponse = self.signedResponseDict
            controller.dictProperty = self.dictProperty
            controller.isFromSignature = true
        }
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

    @IBAction func btnDecline_Tapped(sender: AnyObject) {
        self.declineMessage()
    }

    @IBAction func btnContinue_Tapped(sender: AnyObject) {
        if let signatureImage = self.drawSignatureView.getSignature() {
            
            self.sendSignature(signatureImage)
            
            
        }
    }

    @IBAction func btnClear_Tapped(sender: AnyObject) {
        self.drawSignatureView.clearSignature()
    }
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr.memory.ifa_next }
                
                let interface = ptr.memory
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface.ifa_addr.memory.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if let name = String.fromCString(interface.ifa_name) where name == "en0" {
                        
                        // Convert interface address to a human readable string:
                        var addr = interface.ifa_addr.memory
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        getnameinfo(&addr, socklen_t(interface.ifa_addr.memory.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String.fromCString(hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    @IBAction func btnProperty_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
