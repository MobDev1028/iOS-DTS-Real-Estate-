//
//  SearchPropertiesViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 22/08/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import MBProgressHUD

protocol SearchPropertiesDelegate {
    func didPressedDoneButton(isAgent: Bool)
}

class SearchPropertiesViewController: BaseViewController {
    @IBOutlet weak var txtEnd: UITextField!
    @IBOutlet weak var segmentAgentOption: UISegmentedControl!
    @IBOutlet weak var txtFrequency: UITextField!
    @IBOutlet weak var txtStart: UITextField!
    @IBOutlet weak var viewAgentOptions: UIView!
    @IBOutlet weak var viewAgentConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentBed: UISegmentedControl!
    @IBOutlet weak var segmentBaths: UISegmentedControl!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnUnitAnimities: UIButton!
    @IBOutlet weak var btnShowMoreFilter: UIButton!
    @IBOutlet weak var btnBuildingAnimities: UIButton!
    @IBOutlet weak var constraintButtonMoreFilter: NSLayoutConstraint!
    @IBOutlet weak var viewDefaultFilters: UIView!
    @IBOutlet weak var viewMoreFilters: UIView!
    @IBOutlet weak var lblPriceRange: UILabel!
    @IBOutlet weak var constraintHeightViewMoreFilters: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnShortTerm: UIButton!
    @IBOutlet weak var btnLongTerm: UIButton!
    
    var hud: MBProgressHUD!
    var selectedCoordinates: CLLocationCoordinate2D?
    var latitude: String?
    var longitude: String?
    var rangeSlider1: RangeSlider!
    var listingType: NSMutableArray!
    var terms: NSMutableArray!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    private var responseData:NSMutableData?
    private var dataTask:NSURLSessionDataTask?
    var delegate: SearchPropertiesDelegate?
    var lowerPrice: String!
    var upperPrice: String!
    var isPropertySearch: Bool!
    var dictListing: NSDictionary!
    var dictTerm: NSDictionary!
    var dictAgentOptions: NSMutableDictionary?
    var dictAgentOptionsMap: NSMutableDictionary?
    var customPicker: CustomPickerView?
    var autoCompleteLocations: [String]?
    var currentLocationSelected: Bool!
    
    
    private let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    private let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    @IBAction func backButton_Tapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func resetSearchSettingsButtonTapped(sender: AnyObject) {
        self.constraintButtonMoreFilter.constant = 30
        self.btnShowMoreFilter.hidden = false
        self.constraintHeightViewMoreFilters.constant = 0
        self.segmentAgentOption.selectedSegmentIndex = 0
        self.viewAgentConstraintHeight.constant = 0
        self.viewAgentOptions.hidden = true
        AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
//        self.lblPriceRange.text = "Over $800 to $10000"
        self.resetAllControls()
        self.segmentBed.selectedSegmentIndex = -1
        self.segmentBaths.selectedSegmentIndex = -1
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "selectedRegion")
        if self.isPropertySearch == true {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isMoreViewLoaded")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "agentOptions")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isAgent")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "propertySearch")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isMoreViewLoadedMap")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "agentOptionsMap")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isAgentMap")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "mapSearch")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    func resetAllControls() -> Void {
        
        self.autocompleteTextfield.text = ""
        let currentDate = NSDate()
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.txtStart.text = df.stringFromDate(currentDate)
        
        let endDate = NSDate().dateByAddingTimeInterval(60*60*24*7)
        self.txtEnd.text = df.stringFromDate(endDate)
        
        self.txtFrequency.text = "Daily"
        
        lowerPrice = String(Int(0.0 * 10000))
        upperPrice = String(Int(0.2 * 10000))
        
        rangeSlider1.lowerValue = 0.0
        rangeSlider1.upperValue = 0.2
        
        
        
        self.segmentBed.selectedSegmentIndex = -1
        self.segmentBaths.selectedSegmentIndex = -1
        
        Utils.resetAllBttonsInView(self.viewDefaultFilters)
        Utils.resetAllBttonsInView(self.viewMoreFilters)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listingType = NSMutableArray()
        self.terms = NSMutableArray()
        
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        Utils.formateButtonInView(self.viewDefaultFilters)
        Utils.formateButtonInView(self.viewMoreFilters)
        self.constraintHeightViewMoreFilters.constant = 0
        self.viewMoreFilters.clipsToBounds = true
        rangeSlider1 = RangeSlider(frame: CGRectZero)
        
        let btn = self.viewDefaultFilters.viewWithTag(1001) as! UIButton
        btn.selected = true
        terms.addObject("long")
        
        let btnApt = self.viewDefaultFilters.viewWithTag(2) as! UIButton
        btnApt.selected = true
        listingType.addObject("apt")
        
        let btnCondo = self.viewDefaultFilters.viewWithTag(3) as! UIButton
        btnCondo.selected = true
        listingType.addObject((btnCondo.titleLabel?.text!.lowercaseString)!)
        
        let btnHome = self.viewDefaultFilters.viewWithTag(4) as! UIButton
        btnHome.selected = true
        listingType.addObject((btnHome.titleLabel?.text!.lowercaseString)!)
        
        let btnOther = self.viewDefaultFilters.viewWithTag(5) as! UIButton
        btnOther.selected = true
        listingType.addObject((btnOther.titleLabel?.text!.lowercaseString)!)
        
        rangeSlider1.minimumValue = 0.0
        rangeSlider1.maximumValue = 0.6
        
        rangeSlider1.lowerValue = 0.0
        rangeSlider1.upperValue = 0.2
        
        
        rangeSlider1.addTarget(self, action: #selector(SearchPropertiesViewController.rangeSliderValueChanged(_:)), forControlEvents: .ValueChanged)
        self.viewDefaultFilters.addSubview(rangeSlider1)
        self.viewDefaultFilters.sendSubviewToBack(rangeSlider1)
        self.viewDefaultFilters.bringSubviewToFront(autocompleteTextfield)
//        self.lblPriceRange.text = "Over $800 to $10000"
        
        
        configureTextField()
        handleTextFieldInterfaces()
        Utils.formateSingleButton(btnUnitAnimities)
        Utils.formateSingleButton(btnBuildingAnimities)
//        self.btnReset.layer.cornerRadius = 4
//        self.btnReset.layer.borderWidth = 1
//        self.btnReset.layer.borderColor = UIColor(hexString: "dbdae0").CGColor
//        self.btnDone.layer.cornerRadius = 6
//        self.btnDone.clipsToBounds = true
        
        
        
        self.segmentAgentOption.selectedSegmentIndex = 0
        self.viewAgentConstraintHeight.constant = 0
        self.viewAgentOptions.hidden = true
        
        let currentDate = NSDate()
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.txtStart.text = df.stringFromDate(currentDate)
        
        let endDate = NSDate().dateByAddingTimeInterval(60*60*24*7)
        self.txtEnd.text = df.stringFromDate(endDate)
        
        self.txtFrequency.text = "Daily"
        
        lowerPrice = String(Int(0.0 * 10000))
        upperPrice = String(Int(0.2 * 10000))
        
        if self.isPropertySearch == true {
            
            if NSUserDefaults.standardUserDefaults().boolForKey("isMoreViewLoaded") == true {
                self.constraintButtonMoreFilter.constant = 0
                self.btnShowMoreFilter.hidden = true
                self.constraintHeightViewMoreFilters.constant = 276
            }
            
            let dictTemp = NSUserDefaults.standardUserDefaults().objectForKey("agentOptions") as? NSDictionary
            if dictTemp != nil {
                self.dictAgentOptions = dictTemp?.mutableCopy() as? NSMutableDictionary
            }
            else {
                self.dictAgentOptions = NSMutableDictionary()
            }
            
            if NSUserDefaults.standardUserDefaults().boolForKey("isAgent") == true {
                self.segmentAgentOption.selectedSegmentIndex = 1
                self.viewAgentConstraintHeight.constant = 193
                self.viewAgentOptions.hidden = false
                
            }
            
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
                populateFields()
            }
            
        }
        else {
            
            if NSUserDefaults.standardUserDefaults().boolForKey("isMoreViewLoadedMap") == true {
                self.constraintButtonMoreFilter.constant = 0
                self.btnShowMoreFilter.hidden = true
                self.constraintHeightViewMoreFilters.constant = 276
            }
            
            let dictTemp = NSUserDefaults.standardUserDefaults().objectForKey("agentOptionsMap") as? NSDictionary
            if dictTemp != nil {
                self.dictAgentOptionsMap = dictTemp?.mutableCopy() as? NSMutableDictionary
            }
            else {
                self.dictAgentOptionsMap = NSMutableDictionary()
            }
            
            if NSUserDefaults.standardUserDefaults().boolForKey("isAgentMap") == true {
                self.segmentAgentOption.selectedSegmentIndex = 1
                self.viewAgentConstraintHeight.constant = 193
                self.viewAgentOptions.hidden = false
            }
            
            let arrCriteria = Utils.unarchiveSearch("mapSearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
                populateFields()
            }
        }
        
        
        
        
    }
    
    func populateFields() -> Void {
        
        if let selectedRegion = NSUserDefaults.standardUserDefaults().objectForKey("selectedRegion") as? String {
            self.autocompleteTextfield.text = selectedRegion
        }
        
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
    
    @IBAction func actionSegmentClientValueChanged(sender: AnyObject) {
        let segment = sender as! UISegmentedControl
        if self.isPropertySearch == true {
            if segment.selectedSegmentIndex == 0 {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isAgent")
                self.viewAgentConstraintHeight.constant = 0
                self.viewAgentOptions.hidden = true
            }
            else {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isAgent")
                self.viewAgentConstraintHeight.constant = 193
                self.viewAgentOptions.hidden = false
            }
        }
        else {
            if segment.selectedSegmentIndex == 0 {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isAgentMap")
                self.viewAgentConstraintHeight.constant = 0
                self.viewAgentOptions.hidden = true
            }
            else {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isAgentMap")
                self.viewAgentConstraintHeight.constant = 193
                self.viewAgentOptions.hidden = false
            }
        }
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        
//        let geoValue = "\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)|\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)|10"
//        let dictGeo = ["field": "geo", "operator": "=", "value": geoValue]
//        
//        
//        
//        AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictGeo)
        
        if AppDelegate.returnAppDelegate().selectedSearchRegion != nil {
            if let region = AppDelegate.returnAppDelegate().selectedSearchRegion?.componentsSeparatedByString(",").first {
                //{ "field": "region", "operator": "=", "value": "city|New York" }
                let dictRegion = ["field": "region", "operator": "=", "value": "city|\(region)"]
                AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictRegion)
                NSUserDefaults.standardUserDefaults().setObject(AppDelegate.returnAppDelegate().selectedSearchRegion!, forKey: "selectedRegion")
            }
        }
        else {
            let geoValue = "\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)|\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)|10"
            let dictGeo = ["field": "geo", "operator": "=", "value": geoValue]
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "selectedRegion")
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
        
        if self.isPropertySearch == true {
            if self.segmentAgentOption.selectedSegmentIndex == 1 {
                dictAgentOptions?.setObject(self.txtFrequency.text!, forKey: "frequency")
                dictAgentOptions?.setObject(self.txtStart.text!, forKey: "start")
                dictAgentOptions?.setObject(self.txtEnd.text!, forKey: "end")
                NSUserDefaults.standardUserDefaults().setObject(dictAgentOptions?.copy() as! NSDictionary, forKey: "agentOptions")
                
            }
            Utils.archiveSearch(AppDelegate.returnAppDelegate().arrSearchCriteria.copy() as! NSArray, keyTitle: "propertySearch")
            
        }
        else {
            if self.segmentAgentOption.selectedSegmentIndex == 1 {
                dictAgentOptionsMap?.setObject(self.txtFrequency.text!, forKey: "frequency")
                dictAgentOptionsMap?.setObject(self.txtStart.text!, forKey: "start")
                dictAgentOptionsMap?.setObject(self.txtEnd.text!, forKey: "end")
                NSUserDefaults.standardUserDefaults().setObject(dictAgentOptionsMap?.copy() as! NSDictionary, forKey: "agentOptionsMap")
                
            }
            Utils.archiveSearch(AppDelegate.returnAppDelegate().arrSearchCriteria.copy() as! NSArray, keyTitle: "mapSearch")
        }
        
        
        
        self.dismissViewControllerAnimated(true) {
            if self.delegate != nil {
                if self.isPropertySearch == true {
                    
                    self.delegate?.didPressedDoneButton(NSUserDefaults.standardUserDefaults().boolForKey("isAgent"))
                }
                else {
                    self.delegate?.didPressedDoneButton(NSUserDefaults.standardUserDefaults().boolForKey("isAgentMap"))
                }
            }
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
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider1.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + 100,
                                    width: width, height: 31.0)
        lblPriceRange.frame = CGRect(x: margin, y: lblPriceRange.frame.origin.y,
                                     width: width, height: 31.0)
    }
    
    @IBAction func actionLaodMoreFilters(sender: AnyObject) {
        self.constraintButtonMoreFilter.constant = 0
        self.btnShowMoreFilter.hidden = true
        self.constraintHeightViewMoreFilters.constant = 276
        if self.isPropertySearch == true {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isMoreViewLoaded")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isMoreViewLoadedMap")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetButtonTapped(sender: AnyObject) {
        self.constraintButtonMoreFilter.constant = 30
        self.btnShowMoreFilter.hidden = false
        self.constraintHeightViewMoreFilters.constant = 0
        if self.isPropertySearch == true {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isMoreViewLoaded")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isMoreViewLoadedMap")
            NSUserDefaults.standardUserDefaults().synchronize()
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
                AppDelegate.returnAppDelegate().selectedSearchRegion = nil
                AppDelegate.returnAppDelegate().selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
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
                    AppDelegate.returnAppDelegate().selectedSearchRegion = text
                    AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    
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
    @IBOutlet weak var selectBuildingAnimitiesButtonTapped: UIButton!
    @IBAction func selectUnitAnimitiesButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showFilters", sender: self)
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

extension SearchPropertiesViewController: UITextFieldDelegate {
    
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

extension SearchPropertiesViewController: CustomPickerDelegate {
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
