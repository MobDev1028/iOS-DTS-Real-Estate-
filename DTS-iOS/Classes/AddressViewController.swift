//
//  AddressViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 01/08/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class AddressViewController: BaseViewController {

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtZip: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtApartment: UITextField!
    @IBOutlet weak var txtStreet: UITextField!
    var customPicker: CustomPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtCountry.delegate = self
        self.txtCity.delegate = self
        self.txtState.delegate = self
        self.txtStreet.delegate = self
        self.txtApartment.delegate = self
        self.txtZip.delegate = self
        self.txtStreet.returnKeyType = .Next
        self.txtApartment.returnKeyType = .Next
        self.txtCity.returnKeyType = .Next
        self.txtState.returnKeyType = .Next
        self.txtZip.returnKeyType = .Next
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
    }
    
    
    func getCountries() -> NSArray {
        let codes = NSLocale.ISOCountryCodes() as NSArray
        let countries = NSMutableArray()
        for code in codes {
            let strCode = code as! String
            let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: strCode)
            let dictCountry = ["code": strCode, "title": countryName!] as NSDictionary
            countries.addObject(dictCountry)
        }
        return countries
    }

}

extension AddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.txtApartment.becomeFirstResponder()
            return false
        }
        else if textField.tag == 1 {
            self.txtCity.becomeFirstResponder()
            return false
        }
        if textField.tag == 2 {
            self.txtState.becomeFirstResponder()
            return false
        }
        if (textField.tag == 3) {
            self.txtZip.becomeFirstResponder()
            return false
        }
        
        if textField.tag == 4 {
            self.txtCountry.becomeFirstResponder()
            return false
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag == 5 {
            self.txtZip.resignFirstResponder()
            self.txtState.resignFirstResponder()
            self.txtCountry.resignFirstResponder()
            self.txtCity.resignFirstResponder()
            self.txtApartment.resignFirstResponder()
            self.txtStreet.resignFirstResponder()
            
            let countries = self.getCountries()
            
            self.showPicker(countries, indexPath: NSIndexPath(forRow: textField.tag, inSection: 0), andKey: "title")
            return false
        }
        return true
    }
    
    @IBAction func btnNext_Tapped(sender: AnyObject) {
        
        if Utils.isTextFieldEmpty(self.txtStreet) {
            Utils.showOKAlertRO("", message: "Street address is reqired.", controller: self)
            return
        }
        if Utils.isTextFieldEmpty(self.txtCity) {
            Utils.showOKAlertRO("", message: "City is required.", controller: self)
            return
        }
        if Utils.isTextFieldEmpty(self.txtState) {
            Utils.showOKAlertRO("", message: "State is required.", controller: self)
            return
        }
        if Utils.isTextFieldEmpty(self.txtZip) {
            Utils.showOKAlertRO("", message: "Zip is required.", controller: self)
            return
        }
        if Utils.isTextFieldEmpty(self.txtCountry) {
            Utils.showOKAlertRO("", message: "Country is reqired.", controller: self)
            return
        }
        
        let address1 = self.txtStreet.text!
        let zip = self.txtZip.text!
        let city = self.txtCity.text!
        let State = self.txtState.text!
        let Country = self.txtCountry.text!
        AppDelegate.returnAppDelegate().userProperty.setObject(address1, forKey: "address1")
        AppDelegate.returnAppDelegate().userProperty.setObject(zip, forKey: "zip")
        AppDelegate.returnAppDelegate().userProperty.setObject(city, forKey: "city")
        AppDelegate.returnAppDelegate().userProperty.setObject(State, forKey: "state")
        AppDelegate.returnAppDelegate().userProperty.setObject(Country, forKey: "country")
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ucldetailVC") as! UCLDetailsViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
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

extension AddressViewController: CustomPickerDelegate {
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
        if indexPath.row == 5 {
            self.txtCountry.text = selectedText
        }
    }
}

