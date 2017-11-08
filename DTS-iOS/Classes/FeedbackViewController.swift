//
//  FeedbackViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 20/10/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD

class FeedbackViewController: UIViewController {

    @IBOutlet weak var lblRemainingCharacters: UILabel!
    @IBOutlet weak var btnDisLike: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnSideMenu: UIButton!
    var customPicker: CustomPickerView?
    var hud: MBProgressHUD!
    var isLiked: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        
        let revealController = revealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        let likedDefaultImage = UIImage(named: "smile_face.png")
        let likedSelectedImage = likedDefaultImage?.imageWithRenderingMode(.AlwaysTemplate)
        btnLike.setImage(likedSelectedImage, forState: .Selected)
        btnLike.tintColor = UIColor.greenColor()
        
        let dislikedDefaultImage = UIImage(named: "sad_face.png")
        let dislikedSelectedImage = dislikedDefaultImage?.imageWithRenderingMode(.AlwaysTemplate)
        btnDisLike.setImage(dislikedSelectedImage, forState: .Selected)
        btnDisLike.tintColor = UIColor.greenColor()
        
        self.lblRemainingCharacters.text = "120 remaining"
        self.tvMessage.layer.cornerRadius = 6
        self.tvMessage.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
        self.tvMessage.layer.borderWidth = 1
        self.tvMessage.delegate = self
        self.addDoneButtonOnKeyboard(self.tvMessage)
    }

    @IBAction func dislikeButtonTapped(sender: AnyObject) {
        self.btnDisLike.selected = true
        self.btnLike.selected = false
        self.isLiked = false
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        self.btnDisLike.selected = false
        self.btnLike.selected = true
        self.isLiked = true
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
        if isLiked == nil || Utils.isTextViewEmpty(self.tvMessage) {
            return
        }
        self.hud.show(true)
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String {
            var feedback = "POSITIVE"
            if isLiked == false {
                feedback = "NEGATIVE"
            }
            let dictParams = ["token": token, "type": feedback, "message": self.tvMessage.text!]
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
        let strURL = "https://api.ditchthe.space/api/feedback"
        
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
                            self.hud.hide(true)
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: dict!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            let successVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("successVC") as! SuccessViewController
                            self.navigationController?.pushViewController(successVC, animated: true)
                        })
                        
                        
//                        let _utils = Utils()
//                        _utils.showOKAlert("", message: "Your feedback has been sent.", controller: self, isActionRequired: false)
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

extension FeedbackViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let types = [["id": "1", "title": "Cannot login"], ["id": "1", "title": "Site error"], ["id": "1", "title": "Page won't load"], ["id": "1", "title": "Account issue"], ["id": "1", "title": "General"], ["id": "1", "title": "Other"]]
        self.showPicker(types, indexPath: NSIndexPath(forRow: textField.tag, inSection: 0), andKey: "title")
        return false
    }
}

extension FeedbackViewController: CustomPickerDelegate {
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

extension FeedbackViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        self.lblRemainingCharacters.text = String(120 - newText.characters.count + 1).stringByAppendingString(" remaining")
        return numberOfChars <= 120;
    }
}
