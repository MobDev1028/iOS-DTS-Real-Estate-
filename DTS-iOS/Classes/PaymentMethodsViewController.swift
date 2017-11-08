//
//  PaymentMethodsViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 16/01/2017.
//  Copyright © 2017 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD

class PaymentMethodsViewController: UIViewController {

    @IBOutlet weak var tblLeases: UITableView!
    @IBOutlet weak var viewPayment: UIView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtType: UITextField!
    @IBOutlet weak var txtRouteNumber: UITextField!
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var contraintHeightAddAccountView: NSLayoutConstraint!
    @IBOutlet weak var tblPaymentMethods: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    
    @IBOutlet weak var segment: UISegmentedControl!
    var paymentMethods: [AnyObject] = []
    @IBOutlet weak var viewLeases: UIView!
    var hud: MBProgressHUD!
    var customPicker: CustomPickerView?
    var confirmVerificationIndex = -1
    var leases: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contraintHeightAddAccountView.constant = 0
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        let revealController = revealViewController()
        revealController.panGestureRecognizer().enabled = false
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.addDoneButtonOnKeyboard(self.txtAccountNumber)
        self.addDoneButtonOnKeyboard(self.txtRouteNumber)
        
        self.tblPaymentMethods.dataSource = self
        self.tblPaymentMethods.delegate = self
        
        self.tblLeases.dataSource = self
        self.tblLeases.delegate = self
        
        self.segment.selectedSegmentIndex = 1
        self.viewLeases.hidden = true
        self.viewPayment.hidden = false
        self.getPaymentMethods()
        
    }
    @IBAction func addAccountButtonTapped(sender: AnyObject) {
        contraintHeightAddAccountView.constant = 207
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        contraintHeightAddAccountView.constant = 0
    }
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if Utils.isTextFieldEmpty(self.txtAccountNumber) == true {
            Utils.showOKAlertRO("", message: "Account number is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtRouteNumber) == true {
            Utils.showOKAlertRO("", message: "Route number is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtName) == true {
            Utils.showOKAlertRO("", message: "Name is required.", controller: self)
            return
        }
        
        contraintHeightAddAccountView.constant = 0
        
        self.saveACHPaymentMethod()
    }
    @IBAction func verifyAccountButtonTapped(sender: AnyObject) {
        let btn = sender as! UIButton
        let dictPaymentMethod = self.paymentMethods[btn.tag] as! [String: AnyObject]
        let strId = String(dictPaymentMethod["id"] as! Int)
        self.initiateVerification(strId)
    }

    @IBAction func verifyDepositsButtonTapped(sender: AnyObject) {
        confirmVerificationIndex = (sender as! UIButton).tag
        self.tblPaymentMethods.reloadData()
    }
    
    @IBAction func confirmVerifyDepositsButtonTapped(sender: AnyObject) {
        let btn = sender as! UIButton
        let dictPaymentMethod = self.paymentMethods[btn.tag] as! [String: AnyObject]
        let strId = String(dictPaymentMethod["id"] as! Int)
        let selIndexPath = NSIndexPath(forRow: (sender as! UIButton).tag, inSection: 0)
        let cell = self.tblPaymentMethods.cellForRowAtIndexPath(selIndexPath) as! PaymentMethodTableViewCell
        if Utils.isTextFieldEmpty(cell.txtAmount1) == true {
            Utils.showOKAlertRO("", message: "Amount 1 is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(cell.txtAmount2) == true {
            Utils.showOKAlertRO("", message: "Amount 2 is required.", controller: self)
            return
        }
        
        self.verifyDeposits(strId, amount1: cell.txtAmount1.text!, amount2: cell.txtAmount2.text!)

    }

    
    @IBAction func toggle(sender: AnyObject) {
        self.viewLeases.hidden = true
        self.viewPayment.hidden = true
        
        switch (sender as! UISegmentedControl).selectedSegmentIndex {
        case 0:
            self.viewLeases.hidden = false
            self.getLeases()
            break
        case 1:
            self.viewPayment.hidden = false
            self.getPaymentMethods()
            break
        default:
            break
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func addNextButtonOnKeyboard(view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: #selector(btnNextTapped(_:)))
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
    
    func btnNextTapped(sender: AnyObject) {
        //self.txtViewDescription.becomeFirstResponder()
    }
}

extension PaymentMethodsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return paymentMethods.count
        }
        else {
            return leases.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let dictPaymentMethod = self.paymentMethods[indexPath.row] as! [String: AnyObject]
            let isVerified = dictPaymentMethod["status"] as! String
            let verificationInitiated = dictPaymentMethod["verification_initiated"] as! Bool
            if verificationInitiated {
                if indexPath.row == confirmVerificationIndex {
                    let cell = tableView.dequeueReusableCellWithIdentifier("confirmVerifyDepositCell", forIndexPath: indexPath) as! PaymentMethodTableViewCell
                    cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
                    cell.lblRoute.text = "******\(dictPaymentMethod["routing_number"] as! String)"
                    cell.lblName.text = dictPaymentMethod["name"] as? String
                    cell.btnConfirmVerifyDeposit.tag = indexPath.row
                    
                    cell.txtAmount1.text = ""
                    cell.txtAmount1.layer.cornerRadius = 4
                    cell.txtAmount1.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
                    cell.txtAmount1.layer.borderWidth = 1
                    cell.txtAmount1.keyboardType = .DecimalPad
                    self.addDoneButtonOnKeyboard(cell.txtAmount1)
                    
                    cell.txtAmount2.text = ""
                    cell.txtAmount2.layer.cornerRadius = 4
                    cell.txtAmount2.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
                    cell.txtAmount2.layer.borderWidth = 1
                    cell.txtAmount2.keyboardType = .DecimalPad
                    self.addDoneButtonOnKeyboard(cell.txtAmount2)
                    
                    cell.btnConfirmVerifyDeposit.addTarget(self, action: #selector(PaymentMethodsViewController.confirmVerifyDepositsButtonTapped(_:)), forControlEvents: .TouchUpInside)
                    cell.selectionStyle = .None
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("verifyDepositCell", forIndexPath: indexPath) as! PaymentMethodTableViewCell
                    cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
                    cell.lblRoute.text = "******\(dictPaymentMethod["routing_number"] as! String)"
                    cell.lblName.text = dictPaymentMethod["name"] as? String
                    cell.btnVerifyDeposits.tag = indexPath.row
                    cell.btnVerifyDeposits.addTarget(self, action: #selector(PaymentMethodsViewController.verifyDepositsButtonTapped(_:)), forControlEvents: .TouchUpInside)
                    cell.selectionStyle = .None
                    return cell
                }
                
            }
            else {
                if isVerified == "verified" {
                    let cell = tableView.dequeueReusableCellWithIdentifier("verifiedMethodCell", forIndexPath: indexPath) as! PaymentMethodTableViewCell
                    cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
                    cell.lblRoute.text = "******\(dictPaymentMethod["routing_number"] as! String)"
                    cell.lblName.text = dictPaymentMethod["name"] as? String
                    cell.selectionStyle = .None
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("unverifiedMethodCell", forIndexPath: indexPath) as! PaymentMethodTableViewCell
                    cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
                    cell.lblRoute.text = "******\(dictPaymentMethod["routing_number"] as! String)"
                    cell.lblName.text = dictPaymentMethod["name"] as? String
                    cell.btnRequestInfo.tag = indexPath.row
                    cell.btnRequestInfo.addTarget(self, action: #selector(PaymentMethodsViewController.verifyAccountButtonTapped(_:)), forControlEvents: .TouchUpInside)
                    cell.selectionStyle = .None
                    return cell
                }
            }
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! MessagesTableViewCell
            let dictLease = self.leases[indexPath.row] as! NSDictionary
            let dictProperty = dictLease["property_fields"] as! NSDictionary
            
            cell.lblSubject.text = dictProperty["name"] as? String
            cell.lblAddress.text = dictProperty["address"] as? String
            cell.selectionStyle = .None
            return cell

        }
    }
}

extension PaymentMethodsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView.tag == 1 {
            return 65
        }
        let dictPaymentMethod = self.paymentMethods[indexPath.row] as! [String: AnyObject]
        let isVerified = dictPaymentMethod["status"] as! String
        if isVerified == "verified" {
            return 145
        }
        return 195
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 1 {
            let dictLease = self.leases[indexPath.row] as! NSDictionary
            let billController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("billsVC") as! BillsViewController
            billController.bills = dictLease["bills"] as! [AnyObject]
            self.navigationController?.pushViewController(billController, animated: true)
        }
    }
}

extension PaymentMethodsViewController {
    
    func verifyDeposits(id: String, amount1: String, amount2: String) -> Void {
        self.hud.show(true)
        
        var token = ""
        let strURL = "https://api.ditchthe.space/api/saveuserpaymentaction"
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        }
        
        
        let strParams = "token=\(token)&action=verify&type=ach&id=\(id)&amount1=\(amount1)&amount2=\(amount2)"
        
        
        let paramData = strParams.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
        
        let url = NSURL(string: strURL)
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        request.HTTPBody = paramData
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = Bool(tempData!["success"] as! Int)
                    
                    if isSuccess == false {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hud.hide(true)
                        })
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    
                    self.getPaymentMethods()
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
    
    func initiateVerification(id: String) -> Void {
        self.hud.show(true)
        
        var token = ""
        let strURL = "https://api.ditchthe.space/api/saveuserpaymentaction"
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        }
        
        
        let strParams = "token=\(token)&action=initiate_verification&type=ach&id=\(id)"
        
        
        let paramData = strParams.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
        
        let url = NSURL(string: strURL)
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        request.HTTPBody = paramData
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = Bool(tempData!["success"] as! Int)
                    
                    if isSuccess == false {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hud.hide(true)
                        })
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    
                    self.getPaymentMethods()
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
    
    func saveACHPaymentMethod() -> Void {
        self.hud.show(true)
        
        var token = ""
        let strURL = "https://api.ditchthe.space/api/saveuserpayment"
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        }
        
        
        let strParams = "token=\(token)&type=ach&name=\(self.txtName.text!)&account_number=\(self.txtAccountNumber.text!)&routing_number=\(self.txtRouteNumber.text!)&account_type=\(self.txtType.text!)"
        
        
        let paramData = strParams.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
        
            let url = NSURL(string: strURL)
            let request = NSMutableURLRequest(URL: url!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "POST"
            request.HTTPBody = paramData
            
            let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                if error == nil {
                    do {
                       
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                        let tempData = json as? NSDictionary
                        
                        let isSuccess = Bool(tempData!["success"] as! Int)
                        
                        if isSuccess == false {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hud.hide(true)
                            })
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        self.getPaymentMethods()
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
    
    func showPicker(items: NSArray, indexPath: NSIndexPath, andKey key: String) {
        if self.customPicker != nil {
            self.customPicker?.removeFromSuperview()
            self.customPicker = nil
        }
        self.customPicker = CustomPickerView.createPickerViewWithItmes(items, withIndexPath: indexPath, forKey: key)
        self.customPicker?.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.customPicker?.frame = CGRectMake(self.customPicker!.frame.origin.x, self.customPicker!.frame.origin.y, appDelegate.window!.frame.size.width, self.customPicker!.frame.size.height);
        
        self.customPicker!.center = CGPointMake(self.customPicker!.center.x, (appDelegate.window?.frame.size.height)!+192)
        
        self.view.addSubview(self.customPicker!)
        
        UIView.beginAnimations("bringUp", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPointMake(self.customPicker!.center.x, (appDelegate.window?.frame.size.height)!-170)
        UIView.commitAnimations()
    }
    
    func hideCustomPicker() {
        if self.customPicker == nil {
            return
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UIView.beginAnimations("bringDown", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPointMake(self.customPicker!.center.x, (appDelegate.window?.frame.size.height)!+192)
        UIView.commitAnimations()
    }
}

extension PaymentMethodsViewController {
    func getPaymentMethods() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getuserpayment?token=\(token)")
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
                    let result = json as? NSDictionary
                    
                    let isSuccess = Bool(result!["success"] as! Int)
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    
                    self.confirmVerificationIndex = -1
                    self.paymentMethods = result!["data"]!["ach"] as! [AnyObject]
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tblPaymentMethods.reloadData()
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

extension PaymentMethodsViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag == 2 {
            self.txtAccountNumber.resignFirstResponder()
            self.txtName.resignFirstResponder()
            self.txtType.resignFirstResponder()
            self.txtRouteNumber.resignFirstResponder()
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.showPicker([["title": "Checking"], ["title": "Savings"]], indexPath: indexPath, andKey: "title")
            
            return false
            
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension PaymentMethodsViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(date: NSDate, withIndexPath indexPath: NSIndexPath) {
        
    }
    
    func didDurationSelected(duration: String, withIndexPath indexPath: NSIndexPath) {
        
    }
    
    func didItemSelected(optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: NSIndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        self.txtType.text = selectedText
    }
}

extension PaymentMethodsViewController {
    func getLeases() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getlease?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIxLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzkxMSwiZXhwIjoxNTU3MjQ1OTExLCJuYmYiOjE0NjM5MzM5MTEsImp0aSI6IjdkMGYzNWFiNGM0MzBjNjQ0YWJiN2RlODU0YzAwNDA5In0.5COr5Q6H6FGeVVaTJPHHfZuFZg0A8caLI5ZYCM_x4T8&status=active&from_date=2016-01-01&to_date=2018-01-01&paginated=0")
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
                    let result = json as? NSDictionary
                    
                    let isSuccess = Bool(result!["success"] as! Int)
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    
                    if let dictData = json["data"] as? NSDictionary {
                        self.leases = dictData["data"] as! [AnyObject]
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tblLeases.reloadData()
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
}
