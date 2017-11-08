//
//  UCLPreviewViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 29/11/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD
import GoogleMaps

class UCLPreviewViewController: UIViewController {
    
    @IBOutlet weak var btnSideMenu: UIButton!

    var reqType = 0
    var hud: MBProgressHUD!
    var propertyID: String!
    var propertyImages: NSArray!
    @IBOutlet weak var tblDetail: UITableView!
    var isFromMainView: Bool?
    var amenities = ""
    var highlights = ""
    private let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    var driveDuration: String?
    var distance: String?
    var imgCount: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgCount = 0
        let revealController = revealViewController()
        //        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        
        if let revealController = revealViewController() {
            revealController.panGestureRecognizer().enabled = false
        }
        
        self.tblDetail.estimatedRowHeight = 10.0
        self.tblDetail.rowHeight = UITableViewAutomaticDimension
        
        self.getAddressFromCurrentLocation()
        
    }
    @IBAction func acceptButtonTapped(sender: AnyObject) {
        imgCount = 0
        self.saveProperty()
    }
    @IBAction func editButtonTapped(sender: AnyObject) {
        let controllerToGoBack = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3]
        self.navigationController?.popToViewController(controllerToGoBack!, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    @IBAction func backButton_Tapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}

extension UCLPreviewViewController {
    
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
        var pDescription = ""
        
        //uclClass = AppDelegate.returnAppDelegate().userProperty["uclClass"] as! String
        uclType = AppDelegate.returnAppDelegate().userProperty["uclType"] as! String
        
        beds = AppDelegate.returnAppDelegate().userProperty["beds"] as! String
        baths = AppDelegate.returnAppDelegate().userProperty["baths"] as! String
        pTitle = AppDelegate.returnAppDelegate().userProperty["title"] as! String
        pPrice = AppDelegate.returnAppDelegate().userProperty["price"] as! String
        pDescription = AppDelegate.returnAppDelegate().userProperty["description"] as! String
        
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
                                  "description": pDescription,
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
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hud.hide(true)
                                let _utils = Utils()
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                                return
                            })
                            
                        }
                        
                        let propertyId = tempData!["data"] as! Int
                        let strPropertyId = String(propertyId)
                        AppDelegate.returnAppDelegate().newlyCreatedPropertyId = propertyId
                        
                        let dictParams = ["token": token, "property_id": strPropertyId]
                        
                        for img in self.propertyImages {
                            
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
                        Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    })
                    
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
                dispatch_async(dispatch_get_main_queue(), {
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                })
                
                return
            }
            
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                let tempData = json as? NSDictionary
                
                if tempData!["error"] as? String != nil {
                    let error = tempData!["error"] as! String
                    let _utils = Utils()
                    dispatch_async(dispatch_get_main_queue(), {
                        _utils.showOKAlert("Error:", message: error, controller: self, isActionRequired: false)
                    })
                    
                    return
                }
                
                let isSuccess = Bool(tempData!["success"] as! Int)
                
                if isSuccess == false {
                    
                    let _utils = Utils()
                    dispatch_async(dispatch_get_main_queue(), {
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    })
                    
    
                    return
                }
                
                self.imgCount = self.imgCount + 1
                
                if self.imgCount == self.propertyImages.count {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("myDitchVC") as! MyDitchViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                    })
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
    
    
    func getAddressFromCurrentLocation() -> Void {
        
        //self.hud.show(true)
        Location.reverseGeocodeLocation(AppDelegate.returnAppDelegate().currentLocation!, completion: { (placemark, error) in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.hide(true)
                })
                return
            }
            
            if placemark?.name != nil && placemark?.administrativeArea != nil && placemark?.country != nil {
                let currentAddress = ("\(placemark!.name!), \(placemark!.administrativeArea!), \(placemark!.country!)")
                if let destAddress = AppDelegate.returnAppDelegate().userProperty.objectForKey("address1") {
                    self.getDriveDuration(currentAddress, destinationAddress: destAddress as! String)
                }
                
                
            }
        })
    }
    
    func getFormattedAddress(address: String) -> String {
        let addressToReturn = address.stringByReplacingOccurrencesOfString(", ", withString: ",").stringByReplacingOccurrencesOfString(" ", withString: "+")
        return addressToReturn
    }
    
    func getDriveDuration(currentAddress: String, destinationAddress: String) -> Void {
        let formattedCurrentAddress = getFormattedAddress(currentAddress)
        let formattedDesitationAddress = getFormattedAddress(destinationAddress)
        let strURL = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(formattedCurrentAddress)&destinations=\(formattedDesitationAddress)&key=\(googleMapsKey)"
        
        //        let formattedURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.whitespaceCharacterSet())
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    
                    if let rows = json["rows"] as? NSArray {
                        if rows.count > 0 {
                            if let dictElements = rows[0] as? NSDictionary {
                                if let elements = dictElements["elements"] as? NSArray {
                                    if let geoElement = elements[0] as? NSDictionary {
                                        if let status = geoElement["status"] as? String {
                                            if status == "OK" {
                                                if let duration = geoElement["duration"] as? NSDictionary {
                                                    self.driveDuration = duration["text"] as? String
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), {
                                                        let cell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
                                                        if self.driveDuration != nil {
                                                            cell.lblDuration.text = self.driveDuration
                                                            //                                                            cell.lblDuration.text = "1 day 16 hours"
                                                            
                                                        }
                                                        //self.tblDetail.reloadData()
                                                    })
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    print("worked")
                    
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

extension UCLPreviewViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.propertyImages.count > 0 {
            return self.propertyImages.count + 3
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! DetailTableViewCell
            cell.isUCLPreview = true
            cell.bgImages = self.propertyImages
            cell.viewCounter.layer.cornerRadius = 6
            cell.viewCounter.clipsToBounds = true
            
            let lat = AppDelegate.returnAppDelegate().userProperty.objectForKey("propertyLatitude") as! Double
            let long = AppDelegate.returnAppDelegate().userProperty.objectForKey("propertyLongitude") as! Double
            debugPrint("Lat: \(lat), Long: \(long)")
            cell.lat = lat
            cell.long = long
            
            cell.showMap()
            
            let x = cell.cvBG.contentOffset.x
            let w = cell.cvBG.bounds.size.width
            let currentPage = Int(ceil(x/w))
            print("Current Page: \(currentPage)")
            cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
            
            if let price = AppDelegate.returnAppDelegate().userProperty.objectForKey("price") {
                cell.lblprice.text = ("$\(price)/month")
            }
            
            if let address = AppDelegate.returnAppDelegate().userProperty.objectForKey("address1") {
                cell.lblAddress.text = address as? String
            }
            
            
            
            let intBath = Int(AppDelegate.returnAppDelegate().userProperty.objectForKey("baths") as! String)
            let intBeds = Int(AppDelegate.returnAppDelegate().userProperty.objectForKey("beds") as! String)
            let bath = AppDelegate.returnAppDelegate().userProperty.objectForKey("baths") as! String
            let bed = AppDelegate.returnAppDelegate().userProperty.objectForKey("beds") as! String
            
    
            if intBeds > 1 {
                cell.lblBeds.text = ("\(bed)")
                cell.lblBedCaption.text = "Bed Rooms";
            }
            else {
                cell.lblBeds.text = ("\(bed)")
                cell.lblBedCaption.text = "Bed Room";
            }
            
            if intBath > 1 {
                cell.lblBaths.text = ("\(bath)")
                cell.lblBathCaption.text = "Bath Rooms"
            }
            else {
                cell.lblBaths.text = ("\(bath)")
                cell.lblBathCaption.text = "Bath Room"
            }
            
            cell.lblSize.text = ""
            cell.selectionStyle = .None
            return cell
    
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("StreetTableViewCell", forIndexPath: indexPath) as! StreetTableViewCell
            let lat = AppDelegate.returnAppDelegate().userProperty.objectForKey("propertyLatitude") as! Double
            let long = AppDelegate.returnAppDelegate().userProperty.objectForKey("propertyLongitude") as! Double
            debugPrint("Lat: \(lat), Long: \(long)")
            cell.lat = lat
            cell.long = long
            cell.showStreeView()
            cell.fullScreenButton.addTarget(self, action: #selector(PropertyDetailViewController.goStreetView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell", forIndexPath: indexPath) as! DescriptionTableViewCell
            cell.lblTitle.text = AppDelegate.returnAppDelegate().userProperty.objectForKey("title") as? String
            cell.lblDescription.text = AppDelegate.returnAppDelegate().userProperty.objectForKey("description") as? String
            cell.selectionStyle = .None
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! PropertyDetailTableViewCell
        
            cell.ivBG.image = self.propertyImages[indexPath.row - 3] as? UIImage
            
            cell.ivBG.contentMode = .ScaleAspectFill
            cell.ivBG.clipsToBounds = true
            cell.selectionStyle = .None
            return cell
        }
    }
}
