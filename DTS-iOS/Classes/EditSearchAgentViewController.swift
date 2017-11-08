//
//  EditSearchAgentViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 12/01/2017.
//  Copyright © 2017 Rapidzz. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import MBProgressHUD

class EditSearchAgentViewController: BaseViewController {
    
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtEnd: UITextField!
    @IBOutlet weak var txtFrequency: UITextField!
    @IBOutlet weak var txtStart: UITextField!
    @IBOutlet weak var viewAgentOptions: UIView!
    @IBOutlet weak var segmentBed: UISegmentedControl!
    @IBOutlet weak var segmentBaths: UISegmentedControl!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnUnitAnimities: UIButton!
    @IBOutlet weak var btnBuildingAnimities: UIButton!
    @IBOutlet weak var viewDefaultFilters: UIView!
    @IBOutlet weak var viewMoreFilters: UIView!
    @IBOutlet weak var lblPriceRange: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnShortTerm: UIButton!
    @IBOutlet weak var btnLongTerm: UIButton!
    
    var hud: MBProgressHUD!
    var selectedCoordinates: CLLocationCoordinate2D?
    var selectedRegion: String?
    var latitude: String?
    var longitude: String?
    var rangeSlider1: RangeSlider!
    var listingType: NSMutableArray!
    var terms: NSMutableArray!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    private var responseData:NSMutableData?
    private var dataTask:NSURLSessionDataTask?
    
    
    var lowerPrice: String!
    var upperPrice: String!
    
    var dictListing: NSDictionary!
    var dictTerm: NSDictionary!
    
    
    var customPicker: CustomPickerView?
    var autoCompleteLocations: [String]?
    var currentLocationSelected: Bool!
    
    var dictSearchAgent: NSDictionary!
    var dictSearchData: NSDictionary!
    
    var dictSchedule: NSMutableDictionary!
    var searchCriteriaArray: NSMutableArray!
    
    private let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    private let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listingType = NSMutableArray()
        self.terms = NSMutableArray()
        
        let revealController = revealViewController()
        revealController.panGestureRecognizer().enabled = false
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        Utils.formateButtonInView(self.viewDefaultFilters)
        Utils.formateButtonInView(self.viewMoreFilters)
        self.viewMoreFilters.clipsToBounds = true
        rangeSlider1 = RangeSlider(frame: CGRectZero)
    
        
        rangeSlider1.minimumValue = 0.0
        rangeSlider1.maximumValue = 0.6
        
        rangeSlider1.lowerValue = 0.0
        rangeSlider1.upperValue = 0.2
        
        
        rangeSlider1.addTarget(self, action: #selector(SearchPropertiesViewController.rangeSliderValueChanged(_:)), forControlEvents: .ValueChanged)
        self.viewDefaultFilters.addSubview(rangeSlider1)
        self.viewDefaultFilters.sendSubviewToBack(rangeSlider1)
        self.viewDefaultFilters.bringSubviewToFront(autocompleteTextfield)
        
        
        configureTextField()
        handleTextFieldInterfaces()
        Utils.formateSingleButton(btnUnitAnimities)
        Utils.formateSingleButton(btnBuildingAnimities)
        
        
        
        
        
        let currentDate = NSDate()
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.txtStart.text = df.stringFromDate(currentDate)
        
        let endDate = NSDate().dateByAddingTimeInterval(60*60*24*7)
        self.txtEnd.text = df.stringFromDate(endDate)
        
        self.txtFrequency.text = "Daily"
        
        lowerPrice = String(Int(0.0 * 10000))
        upperPrice = String(Int(0.2 * 10000))
        
        self.viewAgentOptions.hidden = false
        
        self.dictSearchData = dictSearchAgent["search_data"] as! NSDictionary
        self.dictSchedule = (self.dictSearchData["schedule"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        AppDelegate.returnAppDelegate().arrSearchCriteria = (self.dictSearchData["criteria"] as! NSArray).mutableCopy() as! NSMutableArray
        
        print(AppDelegate.returnAppDelegate().arrSearchCriteria)
        
        if let frequency = self.dictSchedule["frequency"] as? String {
            self.txtFrequency.text = frequency.capitalizedString
        }
        
        if let startDate = self.dictSchedule["start"] as? String {
            let arrStartDate = startDate.componentsSeparatedByString(" ")
            if arrStartDate.count > 1 {
                self.txtStart.text = arrStartDate[0]
            }
            else {
                self.txtStart.text = startDate
            }
        }
        
        if let endDate = self.dictSchedule["end"] as? String {
            self.txtEnd.text = endDate
        }
        else {
            
            let df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let strStartDate = self.txtStart.text {
                let startDate = df.dateFromString(strStartDate)
                let endDate = startDate!.dateByAddingTimeInterval(60*60*24*7)
                self.txtEnd.text = df.stringFromDate(endDate)
            }
            
        }
        
        populateFields()
        
        
    }
    
    @IBAction func buildingAmenitiesButtonTapped(sender: AnyObject) {
        
        self.performSegueWithIdentifier("showBuildingAmenities", sender: self)
    }
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider1.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + 100,
                                    width: width, height: 31.0)
        lblPriceRange.frame = CGRect(x: margin, y: lblPriceRange.frame.origin.y,
                                     width: width, height: 31.0)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton_Tapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func shortTermButtonTapped(sender: AnyObject) {
        let button = sender as! UIButton
        if button.selected {
            button.selected = false
            for index in (0..<self.terms.count).reverse() {
                if "short" == self.terms[index] as? String {
                    self.terms.removeObjectAtIndex(index)
                }
            }
        }
        else {
            button.selected = true
            self.terms.addObject("short")
        }
        
    }
    
    @IBAction func longTermButtonTapped(sender: AnyObject) {
        let button = sender as! UIButton
        if button.selected {
            button.selected = false
            for index in (0..<self.terms.count).reverse() {
                if "long" == self.terms[index] as? String {
                    self.terms.removeObjectAtIndex(index)
                }
            }
        }
        else {
            button.selected = true
            self.terms.addObject("long")
        }
    }
    
    
    
    @IBAction func actionFiltersSelected(sender: AnyObject) {
        let button = sender as! UIButton
        if button.selected {
            button.selected = false
            if button.titleLabel?.text! == "Apartment" {
                for index in (0..<self.listingType.count).reverse() {
                    if "apt" == self.listingType[index] as? String {
                        self.listingType.removeObjectAtIndex(index)
                    }
                }
            }
            else {
                for index in (0..<self.listingType.count).reverse() {
                    if button.titleLabel?.text?.lowercaseString == self.listingType[index] as? String {
                        self.listingType.removeObjectAtIndex(index)
                    }
                }
            }
            
        }
        else {
            button.selected = true
            
            if button.titleLabel?.text! == "Apartment" {
                self.listingType.addObject("apt")
            }
            else {
                self.listingType.addObject((button.titleLabel?.text?.lowercaseString)!)
            }
            
        }
    }
    
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        //        self.lblPriceRange.text = "Over $(\(Int(rangeSlider.lowerValue * 10000)) to $\(Int(rangeSlider.upperValue * 10000)))"
        let roundedLowerValue = round(rangeSlider.lowerValue / 0.1) * 0.1
        rangeSlider.lowerValue = roundedLowerValue
        
        let roundedUpperValue = round(rangeSlider.upperValue / 0.1) * 0.1
        rangeSlider.upperValue = roundedUpperValue
        
        lowerPrice = String(Int(rangeSlider.lowerValue * 10000))
        upperPrice = String(Int(rangeSlider.upperValue * 10000))
        
    }
    
    private func configureTextField(){
        autocompleteTextfield.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        autocompleteTextfield.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        autocompleteTextfield.autoCompleteCellHeight = 35.0
        autocompleteTextfield.maximumAutoCompleteCount = 20
        autocompleteTextfield.hidesWhenSelected = true
        autocompleteTextfield.hidesWhenEmpty = true
        autocompleteTextfield.enableAttributedText = true
        autocompleteTextfield.isFromMap = true
        autocompleteTextfield.tag = 105
        autocompleteTextfield.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
        autocompleteTextfield.placeholder = "Enter City / Region"
        autocompleteTextfield.showCurrentLocation = true
    }
    
    private func handleTextFieldInterfaces(){
        autocompleteTextfield.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        autocompleteTextfield.onSelect = {[weak self] text, indexpath in
            self!.autocompleteTextfield.resignFirstResponder()
            
            if text == "Current Location" {
                //                self?.currentLocationSelected = true
                self?.selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
                
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self!.hud.show(true)
                })
                Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self!.hud.hide(true)
                    })
                    self!.selectedCoordinates = placemark?.location?.coordinate
                    self?.selectedRegion = text
                    
                    
                })
            }
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
        self.customPicker!.center = CGPointMake(self.customPicker!.center.x, (appDelegate.window?.frame.size.height)!-130)
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
    
    
    func showDatePicker(selectedDate: NSDate, withIndexPath indexPath: NSIndexPath) {
        if self.customPicker != nil {
            self.customPicker?.removeFromSuperview()
            self.customPicker = nil
        }
        
        let currentDate = selectedDate
        self.customPicker = CustomPickerView.createPickerViewWithDate(true, withIndexPath: indexPath, isDateTime: false, andSelectedDate: currentDate)
        self.customPicker?.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.customPicker?.frame = CGRectMake(self.customPicker!.frame.origin.x, self.customPicker!.frame.origin.y, appDelegate.window!.frame.size.width, self.customPicker!.frame.size.height);
        
        self.customPicker!.center = CGPointMake(self.customPicker!.center.x, (appDelegate.window?.frame.size.height)!+192)
        
        self.view.addSubview(self.customPicker!)
        
        UIView.beginAnimations("bringUp", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPointMake(self.customPicker!.center.x, (appDelegate.window?.frame.size.height)!-130)
        UIView.commitAnimations()
    }
    
    @IBAction func segmentBathsValueChanged(sender: AnyObject) {
        
    }
    @IBAction func segmentBedValueChanged(sender: AnyObject) {
        
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        
        if self.selectedRegion != nil {
            if let region = self.selectedRegion?.componentsSeparatedByString(",").first {
                let dictRegion = ["field": "region", "operator": "=", "value": "city|\(region)"]
                AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictRegion)
            }
        }
        else if self.selectedCoordinates != nil {
            let geoValue = "\(self.selectedCoordinates!.latitude)|\(self.selectedCoordinates!.longitude)|10"
            let dictGeo = ["field": "geo", "operator": "=", "value": geoValue]
            AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictGeo)
        }
        
        
        let dictLowerPrice = ["field": "price", "operator": ">=", "value": lowerPrice]
        
        AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictLowerPrice)
        
        if self.rangeSlider1.upperValue == 0.6 {
            let dictUpperPrice = ["field": "price", "operator": "<=", "value": "10000"]
            AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictUpperPrice)
        }
        else {
            let dictUpperPrice = ["field": "price", "operator": "<=", "value": upperPrice]
            AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictUpperPrice)
        }
        
        if segmentBaths.selectedSegmentIndex > -1 {
            let baths = String(segmentBaths.selectedSegmentIndex + 1)
            let dictBath = ["field" : "bath", "operator" : ">=", "value" : baths]
            AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictBath)
        }
        
        if segmentBed.selectedSegmentIndex > -1 {
            let beds = String(segmentBed.selectedSegmentIndex + 1)
            let dictBed = ["field" : "bed", "operator" : "=", "value" : beds]
            AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictBed)
        }
        
        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
            NSUserDefaults.standardUserDefaults().setDouble((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
            NSUserDefaults.standardUserDefaults().setDouble((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
            
            
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if listingType.count > 0 {
            dictListing = ["field" : "type", "operator" : "in", "value" : listingType]
            AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictListing)
        }
        
        if terms.count > 0 {
            dictTerm = ["field" : "term", "operator" : "in", "value" : terms]
            AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictTerm)
        }
        
        
        self.dictSchedule.setObject(self.txtFrequency.text!.lowercaseString, forKey: "frequency")
        self.dictSchedule.setObject(self.txtStart.text!, forKey: "start")
        self.dictSchedule.setObject(self.txtEnd.text!, forKey: "end")
        
        let search_data: NSDictionary = [
            "schedule": self.dictSchedule,
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        self.saveSearchAgent(search_data)
        
    }
    
    @IBAction func selectUnitAnimitiesButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showFilters", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFilters" {
            let unitController = segue.destinationViewController as! UnitAnimitiesViewController
            unitController.constraintValue = 58
        }
        else if segue.identifier == "showBuildingAmenities" {
            let buildingController = segue.destinationViewController as! BuildingAnimitiesViewController
            buildingController.constraintValue = 58
        }
    }
    
    private func fetchAutocompletePlaces(keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)&types=(cities)&components=country:usa"
        let s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        s.addCharactersInString("+&")
        if let encodedString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(s) {
            if let url = NSURL(string: encodedString) {
                let request = NSURLRequest(URL: url)
                dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let predictions = result["predictions"] as? NSArray{
                                        var locations = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            let prediction = (dict["description"] as! String).stringByReplacingOccurrencesOfString(", United States", withString: "")
                                            locations.append(prediction)
                                        }
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.autocompleteTextfield.autoCompleteStrings = locations
                                        })
                                        return
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.autocompleteTextfield.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }


}

extension EditSearchAgentViewController {
    
    func convertDictionaryToJson(dictionary: NSDictionary) -> String {
        
        do {
            let jsonData: NSData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
            return NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
        }
        catch (let exception) {
           print(exception)
        }
        
        return ""
    }
    
    func saveSearchAgent(searchData: NSDictionary) -> Void {
        
        self.hud.show(true)
        
        var strURL = "https://api.ditchthe.space/api/editsearchagent"
        var strToken = ""
        let searchAgentId = String(self.dictSearchAgent["id"] as! Int)
        //let searcAgentId = self.dictSearchAgent["id"] as! Int
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            strToken = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/editsearchagent?token=\(strToken)")
        }
        
        let body: NSDictionary = [
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        print(body)
        
        //let dataSearchData =
        
        let strSearchData = self.convertDictionaryToJson(searchData)
        
        let strParams = "token=\(strToken)&search_agent_id=\(searchAgentId)&disabled=\(String(self.dictSearchAgent["disabled"] as! Int))&name=\(self.dictSearchAgent["name"] as! String)&search_data=\(strSearchData)"
        //let params: NSDictionary = ["token": strToken, "search_agent_id": String(searcAgentId), "disabled": String(self.dictSearchAgent["disabled"] as! Int), "name": self.dictSearchAgent["name"] as! String, "search_data": searchData]
        
        
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
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hud.hide(true)
                        })
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                        let tempData = json as? NSDictionary
                        if tempData != nil {
                            if tempData!["error"] as? String != nil {
                                let error = tempData!["error"] as! String
                                if error == "user_not_found" {
                                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token")
                                    AppDelegate.returnAppDelegate().logOut()
                                    return
                                }
                            }
                        }
                        let isSuccess = Bool(tempData!["success"] as! Int)
                        
                        if isSuccess == false {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hud.hide(true)
                            })
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        let _utils = Utils()
                        _utils.showOKAlert("", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
    
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
    
    func populateFields() -> Void {
        
        
        if AppDelegate.returnAppDelegate().arrSearchCriteria.count > 0 {
            var index = AppDelegate.returnAppDelegate().arrSearchCriteria.count - 1;
            let arrTempSearchCriteria = AppDelegate.returnAppDelegate().arrSearchCriteria.copy() as! NSArray
            lowerPrice = ""
            upperPrice = ""
            for dict in arrTempSearchCriteria {
                let dictField = dict as! NSDictionary
                if dictField["field"] as! String == "geo" {
                    AppDelegate.returnAppDelegate().arrSearchCriteria.removeObject(dictField)
                    
                }
                else if dictField["field"] as! String == "region" {
                    self.autocompleteTextfield.text = dictField["value"]?.componentsSeparatedByString("|").last
                    AppDelegate.returnAppDelegate().arrSearchCriteria.removeObject(dictField)
                    
                }
                else if dictField["field"] as! String == "address" {
                    AppDelegate.returnAppDelegate().arrSearchCriteria.removeObject(dictField)
                }
                else if dictField["field"] as! String == "price" {
                    if dictField["operator"] as! String == ">=" {
                        let lowerValue = Double(dictField["value"] as! String)!/10000
                        self.rangeSlider1.lowerValue = lowerValue
                        lowerPrice = dictField["value"] as! String
                        
                    }
                    else if dictField["operator"] as! String == "<=" {
                        let upperValue = Double(dictField["value"] as! String)!/10000
                        self.rangeSlider1.upperValue = upperValue
                        upperPrice = dictField["value"] as! String
                    }
                    if lowerPrice.characters.count > 0 && upperPrice.characters.count > 0 {
                        //                        self.lblPriceRange.text = "Over $\(lowerPrice) to $\(upperPrice)"
                    }
                    AppDelegate.returnAppDelegate().arrSearchCriteria.removeObject(dictField)
                }
                else if dictField["field"] as! String == "bed" {
                    self.segmentBed.selectedSegmentIndex = (Int(dictField["value"] as! String)! - 1)
                    //                AppDelegate.returnAppDelegate().arrSearchCriteria.removeObjectAtIndex(index)
                    AppDelegate.returnAppDelegate().arrSearchCriteria.removeObject(dictField)
                }
                else if dictField["field"] as! String == "bath" {
                    self.segmentBaths.selectedSegmentIndex = (Int(dictField["value"] as! String)! - 1)
                    //                AppDelegate.returnAppDelegate().arrSearchCriteria.removeObjectAtIndex(index)
                    AppDelegate.returnAppDelegate().arrSearchCriteria.removeObject(dictField)
                }
                else if dictField["field"] as! String == "term" {
                    terms = (dictField["value"] as! NSArray).mutableCopy() as! NSMutableArray
                    if terms.count > 0 {
                        let btnLong = self.viewDefaultFilters.viewWithTag(1001) as! UIButton
                        btnLong.selected = false
                        let btnShort = self.viewDefaultFilters.viewWithTag(1000) as! UIButton
                        btnShort.selected = false
                        
                        for term in terms {
                            if term as! String == "long" {
                                btnLong.selected = true
                            }
                            else if term as! String == "short" {
                                
                                btnShort.selected = true
                            }
                        }
                    }
                    
                    AppDelegate.returnAppDelegate().arrSearchCriteria.removeObject(dictField)
                }
                else if dictField["field"] as! String == "type" {
                    listingType = (dictField["value"] as! NSArray).mutableCopy() as! NSMutableArray
                    if listingType.count > 0 {
                        
                        let btnApt = self.viewDefaultFilters.viewWithTag(2) as! UIButton
                        btnApt.selected = false
                        
                        let btnCondo = self.viewDefaultFilters.viewWithTag(3) as! UIButton
                        btnCondo.selected = false
                        
                        
                        let btnHome = self.viewDefaultFilters.viewWithTag(4) as! UIButton
                        btnHome.selected = false
                        
                        
                        let btnOther = self.viewDefaultFilters.viewWithTag(5) as! UIButton
                        btnOther.selected = false
                        
                        
                        for type in listingType {
                            if type as! String == "apt" {
                                let btn = self.viewDefaultFilters.viewWithTag(2) as! UIButton
                                btn.selected = true
                            }
                            else if type as! String == "condo" {
                                let btn = self.viewDefaultFilters.viewWithTag(3) as! UIButton
                                btn.selected = true
                            }
                            else if type as! String == "house" {
                                let btn = self.viewDefaultFilters.viewWithTag(4) as! UIButton
                                btn.selected = true
                            }
                            else if type as! String == "other" {
                                let btn = self.viewDefaultFilters.viewWithTag(5) as! UIButton
                                btn.selected = true
                            }
                        }
                    }
                    
                    AppDelegate.returnAppDelegate().arrSearchCriteria.removeObject(dictField)
                }
                index = index - 1
            }
        }
        
    }
}

extension EditSearchAgentViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.txtFrequency.resignFirstResponder()
            self.txtStart.resignFirstResponder()
            self.txtEnd.resignFirstResponder()
            self.showPicker([["title": "Daily"], ["title": "Weekly"]], indexPath: NSIndexPath(forRow: textField.tag, inSection: 0), andKey: "title")
            
            return false
        }
        else if textField.tag == 1 {
            self.txtFrequency.resignFirstResponder()
            self.txtStart.resignFirstResponder()
            self.txtEnd.resignFirstResponder()
            
            let df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            self.showDatePicker(df.dateFromString(textField.text!)!, withIndexPath: NSIndexPath(forRow: textField.tag, inSection: 0))
            
            return false
        }
        else if textField.tag == 2 {
            self.txtFrequency.resignFirstResponder()
            self.txtStart.resignFirstResponder()
            self.txtEnd.resignFirstResponder()
            
            let df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            self.showDatePicker(df.dateFromString(textField.text!)!, withIndexPath: NSIndexPath(forRow: textField.tag, inSection: 0))
            
            return false
            
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 105 {
            if autocompleteTextfield.autoCompleteStrings?.count > 0 {
                self.autocompleteTextfield.text = autocompleteTextfield.autoCompleteStrings![0]
                dispatch_async(dispatch_get_main_queue(), {
                    self.hud.show(true)
                })
                Location.geocodeAddressString(self.autocompleteTextfield.text!, completion: { (placemark, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    self.selectedCoordinates = placemark?.location?.coordinate
                    AppDelegate.returnAppDelegate().selectedSearchRegion = self.autocompleteTextfield.text!
                    AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    
                })
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
}

extension EditSearchAgentViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(date: NSDate, withIndexPath indexPath: NSIndexPath) {
        self.hideCustomPicker()
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        if indexPath.row == 1 {
            self.txtStart.text = df.stringFromDate(date)
        }
        else if indexPath.row == 2 {
            self.txtEnd.text = df.stringFromDate(date)
        }
        
    }
    
    func didDurationSelected(duration: String, withIndexPath indexPath: NSIndexPath) {
        
    }
    
    func didItemSelected(optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: NSIndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        if (indexPath.row == 0) {
            self.txtFrequency.text = selectedText
        }
    }
}
