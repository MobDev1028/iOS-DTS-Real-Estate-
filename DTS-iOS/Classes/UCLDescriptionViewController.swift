//
//  UCLDescriptionViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 29/11/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class UCLDescriptionViewController: UIViewController {
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var txtViewRules: UITextView!
    @IBOutlet weak var txtAddress: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let revealController = revealViewController()
        //        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        let titleLeftView = UIView(frame: CGRectMake(0, 0, 5, 40))
        self.txtAddress.leftView = titleLeftView
        self.txtAddress.leftViewMode = .Always
        self.txtAddress.layer.cornerRadius = 4
        self.txtAddress.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
        self.txtAddress.layer.borderWidth = 1
        
        self.txtViewRules.layer.cornerRadius = 6
        self.txtViewRules.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
        self.txtViewRules.layer.borderWidth = 1
        
        self.txtViewDescription.layer.cornerRadius = 6
        self.txtViewDescription.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
        self.txtViewDescription.layer.borderWidth = 1
        
        self.addNextButtonOnKeyboard(self.txtViewRules)
        self.addDoneButtonOnKeyboard(self.txtViewDescription)
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
        self.txtViewDescription.becomeFirstResponder()
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
    
    @IBAction func previewButtonTapped(sender: AnyObject) {
        
        if Utils.isTextFieldEmpty(self.txtAddress) == true {
            Utils.showOKAlertRO("", message: "Address is required.", controller: self)
            return
        }
        
        if Utils.isTextViewEmpty(self.txtViewRules) == true {
            Utils.showOKAlertRO("", message: "Rules are required.", controller: self)
            return
        }
        
        if Utils.isTextViewEmpty(self.txtViewDescription) == true {
            Utils.showOKAlertRO("", message: "Description is required.", controller: self)
            return
        }
        
        
        //AppDelegate.returnAppDelegate().userProperty.setObject(self.txtAddress.text!, forKey: "address1")
    
        AppDelegate.returnAppDelegate().userProperty.setObject(self.txtViewRules.text!, forKey: "rules")
        AppDelegate.returnAppDelegate().userProperty.setObject(self.txtViewDescription.text!, forKey: "description")
        
        let previewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclPreviewVC") as! UCLPreviewViewController
        previewController.propertyImages = AppDelegate.returnAppDelegate().userProperty.objectForKey("propertyImages") as! NSArray
        self.navigationController?.pushViewController(previewController, animated: true)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UCLDescriptionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.txtViewRules.becomeFirstResponder()
            return false
        }
        
        textField.resignFirstResponder()
        return true
    }
}

