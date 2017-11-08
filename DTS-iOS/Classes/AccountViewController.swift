//
//  AccountViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 16/06/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD

class AccountViewController: BaseViewController {
    
    @IBOutlet weak var lblGeneralSavedStamp: UILabel!
    @IBOutlet weak var lblSavedStamp: UILabel!
    @IBOutlet weak var txtpZip: UITextField!
    @IBOutlet weak var txtCCV: UITextField!
    @IBOutlet weak var txtExpiry: BKCardExpiryField!
    @IBOutlet weak var txtCreditCardNumber: BKCardNumberField!
    @IBOutlet weak var txtRouteNumber: UITextField!
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var svPayment: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var viewPayment: UIView!
    @IBOutlet weak var svGeneral: UIScrollView!
    
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtZipCode: UITextField!
    @IBOutlet weak var txtAddress2: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var viewGeneral: UIView!
    @IBOutlet weak var segmentAccount: UISegmentedControl!
    var dictUserGeneral: NSDictionary!
    var dictUserPayment: NSDictionary!
    var viewType: Int!
    
    var hud: MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        //        Utils.setPaddingForTextFieldInView(self.svGeneral)
        //        Utils.setPaddingForTextFieldInView(self.svPayment)
        
        self.txtExpiry.clearButtonMode = .Never
        self.txtCreditCardNumber.clearButtonMode = .Never
        self.addDoneButtonOnKeyboard(self.txtExpiry)
        self.addDoneButtonOnKeyboard(self.txtCreditCardNumber)
        self.addDoneButtonOnKeyboard(self.txtAccountNumber)
        self.addDoneButtonOnKeyboard(self.txtRouteNumber)
        self.addDoneButtonOnKeyboard(self.txtCCV)
        
        self.txtFirstName.text = dictUserGeneral["firstName"] as! String
        
//        let revealController = revealViewController()
//        revealController.panGestureRecognizer()
//        revealController.tapGestureRecognizer()
//        
//        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        self.segmentAccount.hidden = true
        self.viewGeneral.hidden = true
        self.viewPayment.hidden = true
        
        switch viewType {
        case 0:
            self.viewGeneral.hidden = false
            self.getUserGeneralInfo()
        case 1:
            self.viewPayment.hidden = false
            self.getUserPaymentInfo()
        default:
            break
        }
    }
    
    func getUserGeneralInfo() -> Void {
        
        self.hud.show(true)
        
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getusergeneral?token=\(token)")
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
                        self.hud.hide(true)
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    self.dictUserGeneral = tempData!["data"] as! NSDictionary
                    dispatch_async(dispatch_get_main_queue(), {
                        self.populateUserGeneralFields()
                    })
                    
                    self.getUserPaymentInfo()
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
    
    func populateUserGeneralFields() -> Void {
        
        self.txtFirstName.text = self.dictUserGeneral["first_name"] as? String
        self.txtLastName.text = self.dictUserGeneral["last_name"] as? String
        self.txtEmailAddress.text = self.dictUserGeneral["email"] as? String
        self.txtAddress.text = self.dictUserGeneral["address1"] as? String
        self.txtAddress2.text = self.dictUserGeneral["address2"] as? String
        self.txtZipCode.text = self.dictUserGeneral["zip"] as? String
        
    }
    
    func populateUserPaymentFields() -> Void {
        if self.dictUserPayment["ach"] as? NSDictionary != nil {
            let dictACH = self.dictUserPayment["ach"] as! NSDictionary
            self.txtAccountNumber.text = dictACH["bank_acct"] as? String
            self.txtRouteNumber.text = dictACH["bank_route"] as? String
        }
        if self.dictUserPayment["cc"] as? NSDictionary != nil {
            let dictCC = self.dictUserPayment["cc"] as! NSDictionary
            self.txtCreditCardNumber.text = dictCC["cc"] as? String
            self.txtCCV.text = dictCC["ccv"] as? String
            self.txtExpiry.text = dictCC["expiration"] as? String
            self.txtpZip.text = dictCC["zip"] as? String
        }
    }
    
    func getUserPaymentInfo() -> Void {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.hud.hide(true)
        })
        
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getuserpayment?token=\(token)")
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
                    self.dictUserPayment = tempData!["data"] as! NSDictionary
                    dispatch_async(dispatch_get_main_queue(), {
                        self.populateUserPaymentFields()
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
    
    @IBAction func btnPaymentSave_Tapped(sender: AnyObject) {
        self.saveUserPayment()
    }
    @IBAction func btnGeneralSave_Tapped(sender: AnyObject) {
        self.saveUserGeneralInfo()
    }
    
    func saveUserGeneralInfo() -> Void {
        
        if Utils.isTextFieldEmpty(self.txtFirstName) == true {
            Utils.showOKAlertRO("", message: "First name is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtLastName) == true {
            Utils.showOKAlertRO("", message: "Last name is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtEmailAddress) == true {
            Utils.showOKAlertRO("", message: "Email is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtAddress) == true {
            Utils.showOKAlertRO("", message: "Address 1 is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtZipCode) == true {
            Utils.showOKAlertRO("", message: "Zip codeis required.", controller: self)
            return
        }
        
        if Utils.validateEmailAddress(self.txtEmailAddress.text!) == false {
            Utils.showOKAlertRO("", message: "Email is invalid", controller: self)
            return
        }
        
        
        self.hud.show(true)
        
        var token = ""
        let strURL = "https://api.ditchthe.space/api/saveusergeneral"
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        }
        
        
        var address2 = ""
        if self.txtAddress2.text != nil {
            address2 = self.txtAddress2.text!
        }
        
        
        let paramDict: NSDictionary = ["token": token, "first_name": self.txtFirstName.text!, "last_name": self.txtLastName.text!, "email": self.txtEmailAddress.text!, "address1": self.txtAddress.text!, "address2": address2, "zip": self.txtZipCode.text!]
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
                            self.hud.hide(true)
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        let currentDate = NSDate()
                        let df = NSDateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        self.lblGeneralSavedStamp.text = "Saved \(df.stringFromDate(currentDate))"
                        //                let _utils = Utils()
                        //                _utils.showOKAlert("", message: tempData["message"] as! String, controller: self, isActionRequired: false)
                        //                return
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
    
    func saveUserPayment() -> Void {
        
        
        if Utils.isTextFieldEmpty(self.txtAccountNumber) == false || Utils.isTextFieldEmpty(self.txtRouteNumber) == false {
            if Utils.isTextFieldEmpty(self.txtAccountNumber) == true {
                Utils.showOKAlertRO("", message: "Account number is required.", controller: self)
                return
            }
            
            if Utils.isTextFieldEmpty(self.txtRouteNumber) == true {
                Utils.showOKAlertRO("", message: "Route number is required.", controller: self)
                return
            }
        }
        else {
            if Utils.isTextFieldEmpty(self.txtCreditCardNumber) == false || Utils.isTextFieldEmpty(self.txtExpiry) == false || Utils.isTextFieldEmpty(self.txtCCV) == false || Utils.isTextFieldEmpty(self.txtpZip) == false {
                if Utils.isTextFieldEmpty(self.txtCreditCardNumber) == true {
                    Utils.showOKAlertRO("", message: "Card number is required.", controller: self)
                    return
                }
                
                if Utils.isTextFieldEmpty(self.txtExpiry) == true {
                    Utils.showOKAlertRO("", message: "Expiry is required.", controller: self)
                    return
                }
                
                if Utils.isTextFieldEmpty(self.txtCCV) == true {
                    Utils.showOKAlertRO("", message: "CCV is required.", controller: self)
                    return
                }
                
                if Utils.isTextFieldEmpty(self.txtpZip) == true {
                    Utils.showOKAlertRO("", message: "Zip code is required.", controller: self)
                    return
                }
            }
        }
        
        
        
        self.hud.show(true)
        
        var token = ""
        let strURL = "https://api.ditchthe.space/api/saveuserpayment"
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        }
        
        var accountNumber = ""
        var bankRoute = ""
        var ccno = ""
        var expirey = ""
        var ccv = ""
        var zip = ""
        
        if self.txtAccountNumber.text != nil {
            accountNumber = self.txtAccountNumber.text!
        }
        if self.txtRouteNumber.text != nil {
            bankRoute = self.txtRouteNumber.text!
        }
        if self.txtCreditCardNumber.text != nil {
            ccno = self.txtCreditCardNumber.text!
        }
        if self.txtExpiry.text != nil {
            expirey = self.txtExpiry.text!
        }
        if self.txtCCV.text != nil {
            ccv = self.txtCCV.text!
        }
        if self.txtpZip.text != nil {
            zip = self.txtpZip.text!
        }
        
        let paramDict: NSDictionary = ["token": token, "bank_acct": accountNumber, "bank_route": bankRoute, "cc": ccno, "expiration": expirey, "ccv": ccv, "zip": zip]
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
                            self.hud.hide(true)
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        let currentDate = NSDate()
                        let df = NSDateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        self.lblSavedStamp.text = "Saved \(df.stringFromDate(currentDate))"
                        
                        //                let _utils = Utils()
                        //                _utils.showOKAlert("", message: tempData["message"] as! String, controller: self, isActionRequired: false)
                        //                return
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
    
    @IBAction func btnBack_Tapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func Toggle(sender: AnyObject) {
        let segment = sender as! UISegmentedControl
        self.viewGeneral.hidden = true
        self.viewPayment.hidden = true
        
        if segment.selectedSegmentIndex == 0 {
            self.viewGeneral.hidden = false
        }
        else {
            self.viewPayment.hidden = false;
        }
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
}

extension AccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.txtLastName.becomeFirstResponder()
            return false
        }
        else if textField.tag == 1 {
            self.txtEmailAddress.becomeFirstResponder()
            return false
        }
        else if textField.tag == 2 {
            self.txtAddress.becomeFirstResponder()
            return false
        }
        else if textField.tag == 3 {
            self.txtAddress2.becomeFirstResponder()
            return false
        }
        else if textField.tag == 4 {
            self.txtZipCode.becomeFirstResponder()
            return false
        }
        else if textField.tag == 5 {
            textField.resignFirstResponder()
            return true
        }
        else if textField.tag == 6 {
            self.txtRouteNumber.becomeFirstResponder()
            return false
        }
        else if textField.tag == 7 {
            self.txtCreditCardNumber.becomeFirstResponder()
            return false
        }
        else if textField.tag == 8 {
            self.txtExpiry.becomeFirstResponder()
            return false
        }
        else if textField.tag == 9 {
            self.txtCCV.becomeFirstResponder()
            return false
        }
        else if textField.tag == 10 {
            self.txtpZip.becomeFirstResponder()
            return false
        }
        textField.resignFirstResponder()
        return true
    }
}
