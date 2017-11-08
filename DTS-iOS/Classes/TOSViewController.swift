//
//  TOSViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 20/10/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

import MBProgressHUD

class TOSViewController: BaseViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var btnSideMenu: UIButton!
    var hud: MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let revealController = revealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        
        self.hud.show(true)
        self.getTOS()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getTOS() -> Void {
        var strURL = "https://api.ditchthe.space/api/tos?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFhE"
        
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/tos?token=\(token)")
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
                    let dictData = json as? NSDictionary
                
                let isSuccess = Bool(dictData!["success"] as! Int)
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: dictData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                if let html = dictData!["data"] as? String {
                    let htmlWithArial = "<font face='Arial'>\(html)</font>"
                    self.webView.loadHTMLString(htmlWithArial, baseURL: nil)
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
