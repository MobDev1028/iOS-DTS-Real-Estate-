//
//  Utils.swift
//  ConnetBexio-iOS
//
//  Created by Andy Nyberg on 21/02/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import QuartzCore

protocol UtilsDelegate {
    func didPressedOkayButton()
}

class Utils: NSObject {
    
    var delegate: UtilsDelegate?
    
    class func formateButtonInView(view: UIView) -> Void {
        for subView in view.subviews {
            if subView.isKindOfClass(UIButton) {
                let button = subView as! UIButton
                if button.tag < 100 {
                    button.setBackgroundImage(UIImage(named: "filter_default.png"), forState: .Normal)
                    button.setBackgroundImage(UIImage(named: "filter_selected.png"), forState: .Selected)
                    button.contentHorizontalAlignment = .Left
                    button.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0)
                }
            }
        }
    }
    
    class func formateStringToDate(strDate: String) -> NSDate {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = df.dateFromString(strDate)
        return date!
    }
    
    class func calculateDaysBetweenDates(currentDate: String, createdDate: String) -> Int {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fromDate = df.dateFromString(createdDate)
        //let toDate = df.dateFromString(currentDate)
        let currentCalendar = NSCalendar.currentCalendar()
        let timeUnitDay = NSCalendarUnit.Day
        
        let daysBetween = currentCalendar.component(timeUnitDay, fromDate: fromDate!)
        return daysBetween
    }
    
    class func suffixNumber(number:NSNumber) -> NSString {
        
        var num:Double = number.doubleValue;
        let sign = ((num < 0) ? "-" : "" );
        
        num = fabs(num);
        
        if (num < 1000.0){
            let numAsInt = Int(num)
            return "\(sign)\(numAsInt)";
        }
        
        let exp:Int = Int(log10(num) / 3.0 );
        
        let units:[String] = ["K","M","G","T","P","E"];
        
        let roundedNum:Double = round(100 * num / pow(1000.0,Double(exp))) / 100;
        
        var strRoundedNum = String(roundedNum)
        
        strRoundedNum = strRoundedNum.stringByReplacingOccurrencesOfString(".0", withString: "")
        
        let digitstAfterDecimal = strRoundedNum.componentsSeparatedByString(".")
        if digitstAfterDecimal.count > 0 {
            let strDecimalDigits = digitstAfterDecimal.last
            if strDecimalDigits!.characters.count > 1 {
                strRoundedNum = String(strRoundedNum.characters.dropLast())
            }
        }
        
        
        return "\(sign)\(strRoundedNum)\(units[exp-1])";
        
        
//        if num % 100 == 0 {
//            let roundedNumToBeReturned = Int(roundedNum)
//            return "\(sign)\(roundedNumToBeReturned)\(units[exp-1])";
//        }
//        else {
//            return "\(sign)\(roundedNum)\(units[exp-1])";
//        }
    }
    
    class func resetAllBttonsInView(view: UIView) -> Void {
        for subView in view.subviews {
            if subView.isKindOfClass(UIButton) {
                let button = subView as! UIButton
                if button.tag < 100 {
                    button.selected = false
                }
            }
        }
    }
    
    class func formateSingleButton(button: UIButton) -> Void {
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(hexString: "e7e7e7")
        button.clipsToBounds = true
    }
    
    class func setPaddingForTextFieldInView(view: UIView) ->Void {
        for subView in view.subviews {
            if subView.isKindOfClass(UITextField) {
                let textField = subView as! UITextField
                let paddingView = UIView(frame: CGRectMake(0, 0, 5, 20))
                textField.leftView = paddingView
                textField.leftViewMode = .Always
                textField.layer.borderColor = UIColor.grayColor().CGColor
                textField.layer.borderWidth = 1
            }
        }
    }

    
    func showOKAlert(title: String, message: String, controller: UIViewController, isActionRequired: Bool)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (alertAction) in
            if isActionRequired == true {
                if self.delegate != nil {
                    self.delegate?.didPressedOkayButton()
                }
            }
        }))
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func showOKAlertRO(title: String, message: String, controller: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func isTextFieldEmpty(textField: UITextField) -> Bool {
        if textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters.count == 0 {
            return true
        }
        return false
    }
    
    class func isTextViewEmpty(textView: UITextView) -> Bool {
        if textView.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters.count == 0 {
            return true
        }
        return false
    }
    
    class func validateEmailAddress(candidate: String) -> Bool {
        let emailRegex = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluateWithObject(candidate)
    }
    
    class func archiveSearch(array: NSArray, keyTitle: String) -> Void {
        let data = NSKeyedArchiver.archivedDataWithRootObject(array)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: keyTitle)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func unarchiveSearch(keyTitle: String) -> NSArray? {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(keyTitle) as? NSData
        if data == nil {
            return nil
        }
        let arrayToReturn = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? NSArray
        return arrayToReturn
    }
    
    class func archiveDict(dict: NSDictionary!) -> Void {
        let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "dictMetaData")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func unarchiveData() -> NSDictionary {
        let data = NSUserDefaults.standardUserDefaults().objectForKey("dictMetaData") as! NSData
        let dictToReturn = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
        return dictToReturn
    }
    
    class func archiveArray(array: NSArray, forKey key: String) -> Void {
        let data = NSKeyedArchiver.archivedDataWithRootObject(array)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func unarchiveDataForKey(key: String) -> NSArray? {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSData {
            let arrToReturn = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray
            return arrToReturn
        }
        return nil
    }
    
    class func saveImageJPG(image: UIImage, projectID: Int) -> Bool
    {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        documentsPath = ("\(documentsPath)/\(projectID).jpg")
        print(documentsPath)
        let imageData = UIImageJPEGRepresentation(image, 0.75)
        if imageData!.writeToFile(documentsPath, atomically: true) {
            return true
        }
        return false
    }
    
    class func saveImage(image: UIImage, projectID: Int) -> Bool
    {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        documentsPath = ("\(documentsPath)/\(projectID).png")
        
        let imageData = UIImagePNGRepresentation(image)
        if imageData!.writeToFile(documentsPath, atomically: true) {
            return true
        }
        return false
    }
    
    class func loadImagePath(projectID : Int32) -> String  {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        documentsPath = ("\(documentsPath)/\(projectID).png")
        return documentsPath
    }
    
    class func scaleUIImageToSize( image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    

}


