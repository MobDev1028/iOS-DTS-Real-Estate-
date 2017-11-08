//
//  DocMessageViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 21/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

import MBProgressHUD


class DocMessageViewController: BaseViewController {
    
    
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var wvBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var btnSign: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var ivProperty: UIImageView!
    var dictSelectedMessage: NSDictionary!
    var isFromSignature: Bool!
    var documentPath: NSURL!
    var hud: MBProgressHUD!
    var dictSignedResponse: NSDictionary!
    var dictProperty: NSDictionary!
    
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
        
        self.btnSign.hidden = false
        self.btnDecline.hidden = false
        self.wvBottomConstraint.constant = 87
        
        self.btnAccount.hidden = true
//        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
//            self.btnAccount.hidden = false
//        }
        
        
        
        if dictSelectedMessage["declined"] as! Int != 0 {
            self.wvBottomConstraint.constant = 0
            self.btnSign.hidden = true
            self.btnDecline.hidden = true
            self.downloadDocument()
        }
        else if dictSelectedMessage["doc"] as? NSDictionary != nil {
            if dictSelectedMessage["doc"]!["signed"] as! Int != 0 {
                self.wvBottomConstraint.constant = 0
                self.btnSign.hidden = true
                self.btnDecline.hidden = true
                self.downloadConfirmedSignedDocument()
            }
            else {
                if self.isFromSignature == true {
                    self.btnSign.setTitle("Confirm", forState: .Normal)
                    self.downloadSignedDoc()
                }
                else {
                    self.downloadDocument()
                }
            }
        }
        else {
            if self.isFromSignature == true {
                self.btnSign.setTitle("Confirm", forState: .Normal)
                self.downloadSignedDoc()
            }
            else {
                self.downloadDocument()
            }
        }
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(DocMessageViewController.sendBack))
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
    
    func downloadConfirmedSignedDocument() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getdoccontent?token=\(token)&filename=\(self.dictSelectedMessage["doc"]!["filename"] as! String)&type=signed&title=\(self.dictSelectedMessage["doc_template"]!["title"] as! String)")
            strURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        
        self.hud.show(true)
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                })
                let pdfData = data
                self.writeToPath("\(self.dictSelectedMessage["doc_template"]!["title"] as! String).pdf", data: pdfData!)
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
    
    func downloadSignedDoc() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getdoccontent?token=\(token)&filename=\(self.dictSignedResponse["filename"] as! String)&type=temp&title=\(self.dictSignedResponse["title"] as! String)")
            strURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        
        self.hud.show(true)
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                })
                let pdfData = data
                self.writeToPath("\(self.dictSelectedMessage["doc_template"]!["title"] as! String).pdf", data: pdfData!)
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
    
    func downloadDocument() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getdoccontent?token=\(token)&filename=\(self.dictSelectedMessage["doc_template"]!["filename"] as! String)&type=template&title=\(self.dictSelectedMessage["doc_template"]!["title"] as! String)")
            strURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        
        self.hud.show(true)
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                })
                let pdfData = data
                self.writeToPath("\(self.dictSelectedMessage["doc_template"]!["title"] as! String).pdf", data: pdfData!)
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
    
    func writeToPath(fileName: String, data: NSData) -> Void {
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(fileName)
            print(path)
            
            do {
                try data.writeToURL(path!, options: .DataWritingAtomic)
            }
            catch {
            }
            
            let request = NSURLRequest(URL: path!)
            self.webView.loadRequest(request)

        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "docToSign" {
            let signatureController = segue.destinationViewController as! SignatureViewController
            signatureController.dictSelectedMessage = self.dictSelectedMessage
            signatureController.dictProperty = self.dictProperty
        }
    }
    
    func confirmDocSignature() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            let docId = String(dictSignedResponse["id"] as! Int)
            let msgId = String(dictSelectedMessage["id"] as! Int)
            strURL = ("https://api.ditchthe.space/api/confirmdocsignature?token=\(token)&doc_id=\(docId)&msg_id=\(msgId)")
            strURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
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
                        self.navigationController!.popToRootViewControllerAnimated(true)
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

    
    @IBAction func btnSIgnDoc_Tapped(sender: AnyObject) {
        if self.isFromSignature == false {
            self.performSegueWithIdentifier("docToSign", sender: self)
        }
        else {
            self.confirmDocSignature()
        }
    }
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnDecline_Tapped(sender: AnyObject) {
        self.declineMessage()
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

    @IBAction func btnProperty_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension DocMessageViewController: UIWebViewDelegate {
    
}
