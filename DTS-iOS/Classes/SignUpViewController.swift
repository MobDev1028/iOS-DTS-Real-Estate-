//
//  SignUpViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 12/04/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

import MBProgressHUD

@objc protocol SignupViewControllerDelegate {
    
    optional func didSignedUpSuccessfully()
    optional func didCacnelled()
}

class SignUpViewController: BaseViewController, UITextFieldDelegate, UtilsDelegate {

    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var txtPinCode: AKMaskField!
    @IBOutlet weak var viewPinCode: UIView!
    @IBOutlet weak var viewSending: UIView!
    @IBOutlet weak var viewCID: UIView!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSendPin: UIButton!
    @IBOutlet weak var txtPhoneNumber: AKMaskField!
    var delegate: SignupViewControllerDelegate?
    var propertyId: String?
    var hud: MBProgressHUD!
    var reqType: Int?
    var selectedTag: Int!
    var formattedPhoneNumberForPin: String!
    var plainPhoneNumber: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        
        self.viewCID.alpha = 0
        self.viewPinCode.alpha = 0
        self.viewSending.alpha = 0
        self.viewCID.hidden = false
        self.viewSending.hidden = true
        self.viewPinCode.hidden = true
        
        self.txtPhoneNumber.maskDelegate = self
        self.txtPinCode.maskDelegate = self
        self.txtPhoneNumber.keyboardType = .NumberPad
        self.txtPinCode.keyboardType = .NumberPad
        
//        UIView.animateWithDuration(0.3, animations: {
//            self.viewCID.alpha = 1
//            self.txtPhoneNumber.becomeFirstResponder()
//            self.view.layoutIfNeeded()
//            
//        }) { (finished: Bool) in
//            
//        }
        
        
        
        
        self.btnSendPin.enabled = false
    }
    @IBAction func btnChangePhone_Tapped(sender: AnyObject) {
        resetInputs()
    }
    @IBAction func btnCIDClose_Tapped(sender: AnyObject) {
        self.txtPhoneNumber.resignFirstResponder()
        UIView.animateWithDuration(0.6, animations: {
            self.viewCID.alpha = 0
            
        }) { (finished: Bool) in
            self.viewCID.hidden = true
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    @IBAction func btnPCClose_Tapped(sender: AnyObject) {
        self.txtPinCode.resignFirstResponder()
        UIView.animateWithDuration(0.6, animations: {
            self.viewPinCode.alpha = 0
            
        }) { (finished: Bool) in
            self.viewPinCode.hidden = true
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func  resetInputs() -> Void {
        self.txtPhoneNumber.updateText("")
        self.txtPinCode.updateText("")
        
        self.viewCID.hidden = false
        
        UIView.animateWithDuration(0.6, animations: {
            self.viewCID.alpha = 1
            
        }) { (finished: Bool) in
            self.viewPinCode.alpha = 0
            self.viewPinCode.hidden = true
            self.txtPhoneNumber.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.6, animations: {
            self.viewCID.alpha = 1
            self.txtPhoneNumber.becomeFirstResponder()
            
        }) { (finished: Bool) in

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnSendPin_Tapped(sender: AnyObject) {
        if self.txtPhoneNumber.text?.characters.count == 0 {
            let _utils = Utils()
            _utils.showOKAlert("", message: "Please enter phone number", controller: self, isActionRequired: false)
            return
        }
        
        
        self.formattedPhoneNumberForPin = self.txtPhoneNumber.text?.stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: ".").stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("-", withString: ".")
        
        self.lblPhoneNumber.text = self.formattedPhoneNumberForPin
        
        self.plainPhoneNumber = self.txtPhoneNumber.text?.stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("-", withString: "")
        
        self.viewSending.hidden = false
        self.viewPinCode.hidden = true
        
        UIView.animateWithDuration(0.4, animations: {
            self.viewSending.alpha = 1
            
        }) { (finished: Bool) in
            self.viewCID.alpha = 0
            self.viewCID.hidden = true
        }

        
        requestPinCode(self.plainPhoneNumber)
    }
    
    @IBAction func btnSignUp_Tapped(sender: AnyObject) {
        if self.txtPhoneNumber.text?.characters.count == 0 {
            let _utils = Utils()
            _utils.showOKAlert("", message: "Please enter phone number", controller: self, isActionRequired: false)
            return
        }
        if self.txtPinCode.text?.characters.count == 0 {
            let _utils = Utils()
            _utils.showOKAlert("", message: "Please enter pin code", controller: self, isActionRequired: false)
            return
        }
        
        self.txtPinCode.resignFirstResponder()
        self.txtPhoneNumber.resignFirstResponder()
        
        let params = ["token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImlzcyI6Imh0dHA6XC9cL2R0cy5sb2NhbGhvc3QuY29tXC9hcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ1NjI4MzQ2OSwiZXhwIjoxNTQ5NTk1NDY5LCJuYmYiOjE0NTYyODM0NjksImp0aSI6ImViMWQwNTczMjI5MzkwZGM2MGFmYTJlOWQzNjdkNTJkIn0.2frBoRUv2xdL73g42EY2Jqf8GUiB8YELizcWZELbs9s", "cid": self.txtPhoneNumber.text!, "country_code": "", "code": self.txtPinCode.text!]
        self.registerUser(params)

    }
    
    func addDoneButtonOnKeyboard(view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: view, action: #selector(UIResponder.resignFirstResponder))
        let items = [flexSpace, done]
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        if let accessorizedView = view as? UITextView {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        } else if let accessorizedView = view as? UITextField {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        }
        
    }
    
    func UpdateRootVC() -> Void {
//        let revealVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("revealVC") as! SWRevealViewController
//        AppDelegate.returnAppDelegate().window?.rootViewController = revealVC
        
        let tabbarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("tabbarVC") as! UITabBarController
        AppDelegate.returnAppDelegate().window?.rootViewController = tabbarVC

    }
    
    func hideActiveView() -> Void {
        self.txtPinCode.resignFirstResponder()
        UIView.animateWithDuration(0.6, animations: {
            self.viewPinCode.alpha = 0
            
        }) { (finished: Bool) in
            self.viewPinCode.hidden = true
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func registerUser(dictParam: NSDictionary) -> Void {
//        self.hud.show(true)
    
        let strURL = "https://api.ditchthe.space/api/registeruser?token=\(dictParam["token"] as! String)&cid=\(dictParam["cid"] as! String)&code=\(dictParam["code"] as! String)"
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
                    let token = dict!["data"] as! String
                    if let dicMetaData = dict!["metadata"] as? NSDictionary {
                        if let cid = dicMetaData["cid"] as? String {
                            NSUserDefaults.standardUserDefaults().setObject(cid, forKey: "cid")
                        }
                    }
                    if self.reqType != nil {
                        if self.reqType! == 0 {
                            self.inquireProperty(token, propertyId: self.propertyId!)
                        }
                        else if self.reqType! == 2 {
                            self.likeProperty(token, propertyId: self.propertyId!)
                        }
                        else if self.reqType! == 5 {
                            self.hideProperty(token, propertyId: self.propertyId!)
                        }
                        else {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.txtPinCode.textColor = UIColor.greenColor()
                                self.txtPinCode.resignFirstResponder()
                            })
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2000 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                                
                                UIView.animateWithDuration(0.5, animations: {
                                    self.viewPinCode.alpha = 0
                                    
                                }) { (finished: Bool) in
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.txtPinCode.textColor = UIColor.greenColor()
                                        self.txtPinCode.resignFirstResponder()
                                    })
                                    self.viewPinCode.hidden = true
                                    self.dismissViewControllerAnimated(true, completion: {
                                        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                                        AppDelegate.returnAppDelegate().isFromSignUp = true
                                        AppDelegate.returnAppDelegate().showAnimation = false
                                        
                                        self.UpdateRootVC()
                                    })
                                    
                                }

                            })
                            
    
                        }
                        
                    }
                    else {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.txtPinCode.textColor = UIColor.greenColor()
                            self.txtPinCode.resignFirstResponder()
                        })
                        
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2000 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                            
                            UIView.animateWithDuration(0.5, animations: {
                                self.viewPinCode.alpha = 0
                                
                                
                            }) { (finished: Bool) in
                                self.viewPinCode.hidden = true
                                self.dismissViewControllerAnimated(true, completion: {
                                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                                    AppDelegate.returnAppDelegate().isFromSignUp = true
                                    AppDelegate.returnAppDelegate().showAnimation = false
                                    self.UpdateRootVC()
                                })
                            }
                        })


                    }
                
                    
               
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.txtPinCode.textColor = UIColor.redColor()
                        self.txtPinCode.shake()
                    })

                }
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
    
    func requestPinCode(cid: String) -> Void {
        let strURL = ("https://api.ditchthe.space/api/requestpin?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImlzcyI6Imh0dHA6XC9cL2R0cy5sb2NhbGhvc3QuY29tXC9hcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ1NjI4MzQ2OSwiZXhwIjoxNTQ5NTk1NDY5LCJuYmYiOjE0NTYyODM0NjksImp0aSI6ImViMWQwNTczMjI5MzkwZGM2MGFmYTJlOWQzNjdkNTJkIn0.2frBoRUv2xdL73g42EY2Jqf8GUiB8YELizcWZELbs9s&cid=\(cid)&country_code=")
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
//                self.btnSendPin.setTitle("Click to send pin to your phone number", forState: .Normal)
                if dict!["success"] as! Bool == true {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.viewPinCode.hidden = false
                        
                        UIView.animateWithDuration(0.5, animations: {
                            self.viewPinCode.alpha = 1
                            
                        }) { (finished: Bool) in
                            self.txtPinCode.becomeFirstResponder()
                            self.viewSending.alpha = 0
                            self.viewSending.hidden = true
                        }
                    })
                    
                    
                }
                else {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.viewPinCode.hidden = false
                        self.txtPinCode.textColor = UIColor.blackColor()
                    })
                    
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2000 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                        
                        UIView.animateWithDuration(0.5, animations: {
                            self.viewPinCode.alpha = 1
                            
                        }) { (finished: Bool) in
                            self.txtPinCode.becomeFirstResponder()
                            self.viewSending.alpha = 0
                            self.viewSending.hidden = true
                        }
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
    
    func didPressedOkayButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func hideProperty(token: String, propertyId: String) -> Void {
        //        self.hud.show(true)
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
                    _ = json as? NSDictionary
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.txtPinCode.textColor = UIColor.greenColor()
                        self.txtPinCode.resignFirstResponder()
                    })
                    
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2000 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                        
                        UIView.animateWithDuration(0.5, animations: {
                            self.viewPinCode.alpha = 0
                            
                        }) { (finished: Bool) in
                            self.viewPinCode.hidden = true
                            self.dismissViewControllerAnimated(true, completion: {
                                dispatch_async(dispatch_get_main_queue(), {
                                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                                    AppDelegate.returnAppDelegate().isFromSignUp = true
                                    AppDelegate.returnAppDelegate().showAnimation = false
                                    self.UpdateRootVC()
                                })
                                
                            })
                        }
                    })
                    
                    
                    
                    //                if dict["success"] as! Bool == true {
                    //                    self.txtPinCode.textColor = UIColor.greenColor()
                    //
                    //                    UIView.animateWithDuration(2.5, animations: {
                    //                        self.viewPinCode.alpha = 0
                    //
                    //                    }) { (finished: Bool) in
                    //                        self.viewPinCode.hidden = true
                    //                        self.dismissViewControllerAnimated(true, completion: {
                    //                            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                    //                            AppDelegate.returnAppDelegate().isFromSignUp = true
                    //                            AppDelegate.returnAppDelegate().showAnimation = false
                    //                            self.UpdateRootVC()
                    //                        })
                    //                    }
                    //
                    //                }
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
    
    func inquireProperty(token: String, propertyId: String) -> Void {
//        self.hud.show(true)
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
                    _ = json as? NSDictionary
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.txtPinCode.textColor = UIColor.greenColor()
                        self.txtPinCode.resignFirstResponder()
                    })
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2000 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                
                    UIView.animateWithDuration(0.5, animations: {
                        self.viewPinCode.alpha = 0
                        
                    }) { (finished: Bool) in
                        self.viewPinCode.hidden = true
                        self.dismissViewControllerAnimated(true, completion: {
                            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                            AppDelegate.returnAppDelegate().isFromSignUp = true
                            AppDelegate.returnAppDelegate().showAnimation = false
                            self.UpdateRootVC()
                        })
                    }
                })
                
                
                
//                if dict["success"] as! Bool == true {
//                    self.txtPinCode.textColor = UIColor.greenColor()
//                
//                    UIView.animateWithDuration(2.5, animations: {
//                        self.viewPinCode.alpha = 0
//                        
//                    }) { (finished: Bool) in
//                        self.viewPinCode.hidden = true
//                        self.dismissViewControllerAnimated(true, completion: {
//                            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
//                            AppDelegate.returnAppDelegate().isFromSignUp = true
//                            AppDelegate.returnAppDelegate().showAnimation = false
//                            self.UpdateRootVC()
//                        })
//                    }
//                    
//                }
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
                    
//                    if self.delegate != nil {
//                        self.delegate?.didSignedUpSuccessfully!()
//                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.txtPinCode.textColor = UIColor.greenColor()
                        self.txtPinCode.resignFirstResponder()
                    })
                    
                    
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2000 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                        
                        UIView.animateWithDuration(0.5, animations: {
                            self.viewPinCode.alpha = 0
                            
                        }) { (finished: Bool) in
                            self.viewPinCode.hidden = true
                            self.dismissViewControllerAnimated(true, completion: {
                                NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                                AppDelegate.returnAppDelegate().isFromSignUp = true
                                AppDelegate.returnAppDelegate().showAnimation = false
                                self.UpdateRootVC()
                                if self.delegate != nil {
                                    self.delegate?.didSignedUpSuccessfully!()
                                }
                            })
                        }
                        
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
    
    @IBAction func btnAccount_Tapped(sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func btnCross_Tapped(sender: AnyObject) {
        
//        UIView.animateWithDuration(0.5, animations: { 
//            self.mainScrollCenterConstraint.constant = -600
//            self.view.layoutIfNeeded()
//        }) { (finished: Bool) in
//            self.dismissViewControllerAnimated(false, completion: { 
////                if self.delegate != nil {
////                    self.delegate?.didCacnelled!()
////                }
//            })
//
//        }
        
//        UIView.beginAnimations("bringDown", context:nil)
//        UIView.setAnimationDuration(0.5)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        self.mainScrollCenterConstraint.constant = -600
//        self.view.layoutIfNeeded()
//        UIView.commitAnimations()
    }
}

extension SignUpViewController: AKMaskFieldDelegate {
    func maskFieldDidBeginEditing(maskField: AKMaskField) {
    }
    
    func maskField(maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent) {
        if maskField.tag == 0 {
            switch maskField.maskStatus {
            case .Clear:
                self.btnSendPin.enabled = false
            case .Incomplete:
                self.btnSendPin.enabled = false
            case .Complete:
                self.btnSendPin.enabled = true
            }
        }
        else {
            
            switch maskField.maskStatus {
            case .Clear:
                break
            case .Incomplete:
                break
            case .Complete:
                let params = ["token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImlzcyI6Imh0dHA6XC9cL2R0cy5sb2NhbGhvc3QuY29tXC9hcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ1NjI4MzQ2OSwiZXhwIjoxNTQ5NTk1NDY5LCJuYmYiOjE0NTYyODM0NjksImp0aSI6ImViMWQwNTczMjI5MzkwZGM2MGFmYTJlOWQzNjdkNTJkIn0.2frBoRUv2xdL73g42EY2Jqf8GUiB8YELizcWZELbs9s", "cid": self.plainPhoneNumber, "country_code": "", "code": self.txtPinCode.text!]
                self.registerUser(params)
            }
        }
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.addAnimation(animation, forKey: "shake")
    }
}
