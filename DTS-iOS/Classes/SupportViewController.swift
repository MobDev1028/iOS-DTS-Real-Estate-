//
//  SupportViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 19/10/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD

class SupportViewController: BaseViewController {

    @IBOutlet weak var lblRemainingCharacters: UILabel!
    @IBOutlet weak var btnUnknown: UIButton!
    @IBOutlet weak var btnNoListings: UIButton!
    @IBOutlet weak var btnCrash: UIButton!
    @IBOutlet weak var btnTextCode: UIButton!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var tvMessage: UITextView!
    var customPicker: CustomPickerView?
    var hud: MBProgressHUD!
    var selectedProblem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        
        let revealController = revealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        self.lblRemainingCharacters.text = "120 remaining"
        
        self.tvMessage.delegate = self
        self.tvMessage.layer.cornerRadius = 6
        self.tvMessage.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
        self.tvMessage.layer.borderWidth = 1
        self.addDoneButtonOnKeyboard(self.tvMessage)
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
        
        if self.customPicker != nil {
            self.hideCustomPicker()
        }
        self.tvMessage.resignFirstResponder()
        if selectedProblem == nil || Utils.isTextViewEmpty(self.tvMessage) {
            return
        }
        
        self.hud.show(true)
        
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String {
            //selectedProblem = "other"
            let dictParams = ["token": token, "type": selectedProblem!, "message": self.tvMessage.text!]
            self.sendSupport(dictParams)
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
    
    @IBAction func problemButtonTapped(sender: AnyObject) {
        
        self.btnTextCode.selected = false
        self.btnCrash.selected = false
        self.btnNoListings.selected = false
        self.btnUnknown.selected = false
        
        let btn = sender as! UIButton
        btn.selected = true
        if btn.tag == 10 {
            selectedProblem = "Text Code"
        }
        else if btn.tag == 11 {
            selectedProblem = "Crash"
        }
        else if btn.tag == 12 {
            selectedProblem = "No Listing"
        }
        else if btn.tag == 13 {
            selectedProblem = "Unknonw"
        }
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
    
    func sendSupport(dictParam: NSDictionary) -> Void {
        let strURL = "https://api.ditchthe.space/api/createsupportticket"
        
        do {
            let jsonParamsData = try NSJSONSerialization.dataWithJSONObject(dictParam, options: [])
            
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
                        let dict = json as? NSDictionary
                    let isSuccess = Bool(dict!["success"] as! Int)
                    
                    if isSuccess == false {
                        
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: dict!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            let successVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("successVC") as! SuccessViewController
                            successVC.successMessage = "Your support ticket has been created."
                            self.navigationController?.pushViewController(successVC, animated: true)
                        })
                    
//                    let _utils = Utils()
//                    _utils.showOKAlert("", message: "Your support ticket was created. An agent will contact you soon.", controller: self, isActionRequired: false)
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
}

extension SupportViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let types = [["id": "1", "title": "Cannot login"], ["id": "1", "title": "Site error"], ["id": "1", "title": "Page won't load"], ["id": "1", "title": "Account issue"], ["id": "1", "title": "General"], ["id": "1", "title": "Other"]]
        self.showPicker(types, indexPath: NSIndexPath(forRow: textField.tag, inSection: 0), andKey: "title")
        return false
    }
}

extension SupportViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(date: NSDate, withIndexPath indexPath: NSIndexPath) {
        self.hideCustomPicker()
        let df = NSDateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        
    }
    
    func didDurationSelected(duration: String, withIndexPath indexPath: NSIndexPath) {
        
    }
    
    func didItemSelected(optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: NSIndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
    }
}

extension SupportViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        self.lblRemainingCharacters.text = String(120 - newText.characters.count + 1).stringByAppendingString(" remaining")
        return numberOfChars <= 120;
    }
}
