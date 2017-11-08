//
//  UCLPhotosViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 14/07/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

import MBProgressHUD

class UCLPhotosViewController: BaseViewController, UINavigationControllerDelegate {
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var clvPhotos: UICollectionView!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    var pID: Int!
    var photoIds: NSMutableArray!
    var hud: MBProgressHUD!
    var tmpImg: UIImage!
    var imgCount: Int!
    var progressHud: MBProgressHUD!
    var pPropertyId: Int!
    
    var descriptionController: UCLDescriptionViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let revealController = revealViewController()
//        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        self.pPropertyId = 0
        imgCount = 0
        pID = 0
        clvPhotos.backgroundColor = UIColor.clearColor()
        clvPhotos.dataSource = self
        clvPhotos.delegate = self
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        self.txtPrice.delegate = self
        self.txtTitle.delegate = self
        self.txtPrice.keyboardType = .NumberPad
        photoIds = NSMutableArray()
        let frameView = CGRectMake(0, 0, 45, 40)
        let viewLeft = UIView(frame: frameView)
        let lblFrame = CGRectMake(0, 0, 40, 40)
        let lblCurrencySign = UILabel(frame: lblFrame)
        lblCurrencySign.text = "$"
        lblCurrencySign.backgroundColor = UIColor(hexString: "f1f1f1")
        lblCurrencySign.textAlignment = .Center
        viewLeft.addSubview(lblCurrencySign)
        self.txtPrice.leftView = viewLeft
        self.txtPrice.leftViewMode = .Always
        
        self.txtPrice.layer.cornerRadius = 4
        self.txtPrice.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
        self.txtPrice.layer.borderWidth = 1
        self.addDoneButtonOnKeyboard(self.txtPrice)
        
        self.txtPrice.tag = 100
        
        let titleLeftView = UIView(frame: CGRectMake(0, 0, 5, 40))
        self.txtTitle.leftView = titleLeftView
        self.txtTitle.leftViewMode = .Always
        self.txtTitle.layer.cornerRadius = 4
        self.txtTitle.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
        self.txtTitle.layer.borderWidth = 1
        
        self.txtDescription.layer.cornerRadius = 6
        self.txtDescription.layer.borderColor = UIColor(hexString: "d2d2d2").CGColor
        self.txtDescription.layer.borderWidth = 1
//        self.addDoneButtonOnKeyboard(self.txtDescription)
        self.addNextButtonOnKeyboard(self.txtDescription)
        
        
//        self.progressHud = MBProgressHUD(forView: self.view)
//        self.progressHud.mode = .DeterminateHorizontalBar
//        self.view.addSubview(self.progressHud)
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
        self.txtPrice.becomeFirstResponder()
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
    
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func btnPreview_Tapped(sender: AnyObject) {
        
        if Utils.isTextFieldEmpty(self.txtTitle) == true {
            Utils.showOKAlertRO("", message: "Title is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtPrice) == true {
            Utils.showOKAlertRO("", message: "Price is required.", controller: self)
            return
        }
        
        if self.photoIds.count == 0 {
            Utils.showOKAlertRO("", message: "At-least one image is required.", controller: self)
            return
        }
        
        AppDelegate.returnAppDelegate().userProperty.setObject(self.txtTitle.text!, forKey: "title")
        AppDelegate.returnAppDelegate().userProperty.setObject(self.txtPrice.text!, forKey: "price")
        imgCount = 0
        let allPhotos = NSArray.init(array: self.photoIds)
        AppDelegate.returnAppDelegate().userProperty.setObject(allPhotos, forKey: "propertyImages")
        
        if self.descriptionController == nil {
            self.descriptionController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclDescriptionVC") as? UCLDescriptionViewController
        }
        self.navigationController?.pushViewController(self.descriptionController!, animated: true)
        

    }
    
    func updateProperty() -> Void {
        
        self.hud.show(true)
        
        var token = ""
        var strURL = "https://api.ditchthe.space/api/savepropertyfield"
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("\(strURL)?token=\(token)")
        }
        
        //var uclClass = ""
        var uclType = ""
        //let uclGuests = ""
        var beds = ""
        var baths = ""
        var pTitle = ""
        var pPrice = ""
        
        //uclClass = AppDelegate.returnAppDelegate().userProperty["uclClass"] as! String
        uclType = AppDelegate.returnAppDelegate().userProperty["uclType"] as! String
        
        beds = AppDelegate.returnAppDelegate().userProperty["uclDetailBeds"] as! String
        baths = AppDelegate.returnAppDelegate().userProperty["uclDetailBaths"] as! String
        pTitle = self.txtTitle.text!
        pPrice = self.txtPrice.text!
        
        let address1 = AppDelegate.returnAppDelegate().userProperty["address1"] as! String
        let zip = AppDelegate.returnAppDelegate().userProperty["zip"] as! String
        let city = AppDelegate.returnAppDelegate().userProperty["city"] as! String
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        let country = AppDelegate.returnAppDelegate().userProperty["country"] as! String
        
        let body: NSDictionary = [
            "property_id": AppDelegate.returnAppDelegate().newlyCreatedPropertyId,
            "data": [
                [
                    "field": "type",
                    "value": uclType
                ],
                [
                    "field": "title",
                    "value": pTitle
                ],
                [
                    "field": "description",
                    "value": self.txtDescription.text!
                ],
                [
                    "field": "bed",
                    "value": beds
                ],
                [
                    "field": "bath",
                    "value": baths
                ],
                [
                    "field": "price",
                    "value": pPrice
                ],
                [
                    "field": "address1",
                    "value": address1
                ],
                [
                    "field": "zip",
                    "value": zip
                ],
                [
                    "field": "city",
                    "value": city
                ],
                [
                    "field": "state_or_province",
                    "value": state
                ],
                [
                    "field": "country",
                    "value": country
                ]
            ]
        ]
        
        
        self.hud.show(true)
        
        do {
            let jsonParamsData = try NSJSONSerialization.dataWithJSONObject(body, options: [])
            
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
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hud.hide(true)
                            })
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as! PropertyDetailViewController
                        controller.propertyID = String(AppDelegate.returnAppDelegate().newlyCreatedPropertyId)
                        controller.propertyImages = self.photoIds
                        self.navigationController?.pushViewController(controller, animated: true)
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
    
    func saveProperty() -> Void {
        
        self.hud.show(true)
        
        var token = ""
        var strURL = "https://api.ditchthe.space/api/addproperty"
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("\(strURL)?token=\(token)")
        }
        
        //var uclClass = ""
        var uclType = ""
        //let uclGuests = ""
        var beds = ""
        var baths = ""
        var pTitle = ""
        var pPrice = ""
        
        //uclClass = AppDelegate.returnAppDelegate().userProperty["uclClass"] as! String
        uclType = AppDelegate.returnAppDelegate().userProperty["uclType"] as! String
        
        beds = AppDelegate.returnAppDelegate().userProperty["uclDetailBeds"] as! String
        baths = AppDelegate.returnAppDelegate().userProperty["uclDetailBaths"] as! String
        pTitle = self.txtTitle.text!
        pPrice = self.txtPrice.text!
        
        let address1 = AppDelegate.returnAppDelegate().userProperty["address1"] as! String
        let zip = AppDelegate.returnAppDelegate().userProperty["zip"] as! String
        let city = AppDelegate.returnAppDelegate().userProperty["city"] as! String
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        let country = AppDelegate.returnAppDelegate().userProperty["country"] as! String
        
//        let body: NSDictionary = ["type": uclType,
//                                  "title": pTitle,
//                                  "description": self.txtDescription.text,
//                                  "status": "active",
//                                  "year_built": "2016",
//                                  "lot_size": "560",
//                                  "cat": 0,
//                                  "dog": 0,
//                                  "bed": beds,
//                                  "bath": baths,
//                                  "price": pPrice,
//                                  "term": "month",
//                                  "address1": "1114 lexington ave",
//                                  "address2": "",
//                                  "zip": "10075",
//                                  "city": "New York",
//                                  "state_or_province": "NY",
//                                  "country": "USA",
//                                  "unit_amen_ac": 0,
//                                  "unit_amen_parking_reserved": 0,
//                                  "unit_amen_balcony": 0,
//                                  "unit_amen_deck": 0,
//                                  "unit_amen_ceiling_fan": 0,
//                                  "unit_amen_dishwasher": 0,
//                                  "unit_amen_fireplace": 0,
//                                  "unit_amen_furnished": 0,
//                                  "unit_amen_laundry": 0,
//                                  "unit_amen_floor_carpet": 0,
//                                  "unit_amen_floor_hard_wood": 0,
//                                  "unit_amen_carpet": 0,
//                                  "build_amen_fitness_center": 0,
//                                  "build_amen_biz_center": 0,
//                                  "build_amen_concierge": 0,
//                                  "build_amen_doorman": 0,
//                                  "build_amen_dry_cleaning": 0,
//                                  "build_amen_elevator": 0,
//                                  "build_amen_park_garage": 0,
//                                  "build_amen_swim_pool": 0,
//                                  "build_amen_secure_entry": 0,
//                                  "build_amen_storage": 0,
//                                  "keywords": "keyword1, keyword2"]
        
        let body: NSDictionary = ["type": uclType,
                                  "title": pTitle,
                                  "description": self.txtDescription.text,
                                  "status": "active",
                                  "year_built": "2016",
                                  "lot_size": "560",
                                  "cat": 0,
                                  "dog": 0,
                                  "bed": beds,
                                  "bath": baths,
                                  "price": pPrice,
                                  "term": "month",
                                  "address1": address1,
                                  "address2": "",
                                  "zip": zip,
                                  "city": city,
                                  "state_or_province": state,
                                  "country": country,
                                  "unit_amen_ac": 0,
                                  "unit_amen_parking_reserved": 0,
                                  "unit_amen_balcony": 0,
                                  "unit_amen_deck": 0,
                                  "unit_amen_ceiling_fan": 0,
                                  "unit_amen_dishwasher": 0,
                                  "unit_amen_fireplace": 0,
                                  "unit_amen_furnished": 0,
                                  "unit_amen_laundry": 0,
                                  "unit_amen_floor_carpet": 0,
                                  "unit_amen_floor_hard_wood": 0,
                                  "unit_amen_carpet": 0,
                                  "build_amen_fitness_center": 0,
                                  "build_amen_biz_center": 0,
                                  "build_amen_concierge": 0,
                                  "build_amen_doorman": 0,
                                  "build_amen_dry_cleaning": 0,
                                  "build_amen_elevator": 0,
                                  "build_amen_park_garage": 0,
                                  "build_amen_swim_pool": 0,
                                  "build_amen_secure_entry": 0,
                                  "build_amen_storage": 0,
                                  "keywords": "keyword1, keyword2"]
        
        

        
        self.hud.show(true)
        
        do {
            let jsonParamsData = try NSJSONSerialization.dataWithJSONObject(body, options: [])
            
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
                    
                    let propertyId = tempData!["data"] as! Int
                    let strPropertyId = String(propertyId)
                    AppDelegate.returnAppDelegate().newlyCreatedPropertyId = propertyId
                    
                    let dictParams = ["token": token, "property_id": strPropertyId]
                    
                    for img in self.photoIds {
                        
                        let pImage = img as! UIImage
                        
                        self.uploadMultipartImage(pImage, dictParams: dictParams)
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
        catch {
            
        }
        
    }
    
    func imageWithSize(image: UIImage, size:CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero;
        
        let aspectWidth:CGFloat = size.width / image.size.width;
        let aspectHeight:CGFloat = size.height / image.size.height;
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight);
        
        scaledImageRect.size.width = image.size.width * aspectRatio;
        scaledImageRect.size.height = image.size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        
        image.drawInRect(scaledImageRect);
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage!;
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    func uploadMultipartImage(image: UIImage, dictParams: NSDictionary) -> Void {
        let myUrl = NSURL(string: "https://api.ditchthe.space/api/addpropertyimg");
        //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
        let resizedImage = self.resizeImage(image, newWidth: 1000)
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.75)
        
        if(imageData==nil)  { return; }
        
        request.HTTPBody = createBodyWithParameters(dictParams as? [String : String], filePathKey: "image", imageDataKey: imageData!, boundary: boundary)
        
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.hud.hide(true)
            })
            
            if error != nil {
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
        
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                let tempData = json as? NSDictionary
                
                if tempData!["error"] as? String != nil {
                    let error = tempData!["error"] as! String
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: error, controller: self, isActionRequired: false)
                    return
                }
                
                let isSuccess = Bool(tempData!["success"] as! Int)
                
                if isSuccess == false {

                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.imgCount = self.imgCount + 1
                
                if self.imgCount == self.photoIds.count {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    AppDelegate.returnAppDelegate().userProperty.setObject(self.photoIds, forKey: "propertyImages")
//                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as! PropertyDetailViewController
//                    controller.propertyImages = self.photoIds
//                    controller.propertyID = dictParams["property_id"] as! String
//                    self.navigationController?.pushViewController(controller, animated: true)
                }
                
                
                
            }catch
            {
                print(error)
            }
            
        }
        
        task.resume()
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "propertyFile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    


    
    @IBAction func btnAddPhoto_Tapped(sender: AnyObject) {
        _ = sender as! UIButton
        let actionSheet = UIAlertController(title: "Photo", message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action: UIAlertAction) in
            self.takePhoto()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action: UIAlertAction) in
            self.openLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction) in
            
        }))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func takePhoto() -> Void{
        dispatch_async(dispatch_get_main_queue(), {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        })
    }
    
    func openLibrary() -> Void{
        dispatch_async(dispatch_get_main_queue(), {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        })
    }
}

extension UCLPhotosViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.tmpImg = image
//        let strPID = String(pID)
        photoIds.addObject(image)
//        Utils.saveImage(image, projectID: pID)
//        pID = pID + 1
        self.dismissViewControllerAnimated(true) { 
            self.clvPhotos.reloadData()
        }
    }
    
}

extension UCLPhotosViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 100 {
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 6
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.txtPrice.becomeFirstResponder()
            return false
        }
//        else if textField.tag == 1 {
//            self.txtPrice.becomeFirstResponder()
//            return false
//        }
        
        textField.resignFirstResponder()
        return true
    }
}

extension UCLPhotosViewController: UICollectionViewDataSource {
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.photoIds.count > 0 {
            return self.photoIds.count
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        if self.photoIds.count > 0 {
            cell.ivPhoto.image = self.photoIds[indexPath.row] as? UIImage
        }
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
}

extension UCLPhotosViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let actionSheet = UIAlertController(title: "Photo", message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action: UIAlertAction) in
            self.takePhoto()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action: UIAlertAction) in
            self.openLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction) in
            
        }))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}

extension UCLPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.width, collectionView.bounds.height)
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
