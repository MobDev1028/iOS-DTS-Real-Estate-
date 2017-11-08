//
//  UCLLocationViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 14/07/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MapKit


class UCLLocationViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    var dictSelectedMessage: NSDictionary!
    var dictProperty: NSDictionary!
    var mainTitle: String!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    
    private var responseData:NSMutableData?
    private var dataTask:NSURLSessionDataTask?
    
    @IBOutlet weak var btnSideMenu: UIButton!
    private let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    private let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    var addressController: AddressViewController?
    var detailController: UCLDetailsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTitle.text = self.mainTitle
        configureTextField()
        handleTextFieldInterfaces()
        
        let revealController = revealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)

        let centerCoordinate = AppDelegate.returnAppDelegate().currentLocation!.coordinate
        self.mapView.centerCoordinate = centerCoordinate
        let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 500, 500)
        self.mapView.setRegion(region, animated: true)

        let annotaion = SimpleAnnotation(coordinate: centerCoordinate, title: "", subtitle: "")
        self.mapView.addAnnotation(annotaion)
        
        AppDelegate.returnAppDelegate().userProperty.setObject(AppDelegate.returnAppDelegate().currentLocation!.coordinate.latitude, forKey: "propertyLatitude")
        AppDelegate.returnAppDelegate().userProperty.setObject(AppDelegate.returnAppDelegate().currentLocation!.coordinate.longitude, forKey: "propertyLongitude")
        
        self.getAddressFromLocatio(AppDelegate.returnAppDelegate().currentLocation!.coordinate.latitude, andLongitude: AppDelegate.returnAppDelegate().currentLocation!.coordinate.longitude)
    }
    
    func getAddressFromLocatio(latitude: Double, andLongitude longitude: Double) -> Void {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=AIzaSyCLAdXdnslw3gRzcyzOWl7kogL6Y9l3Rt0"
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let result = json as? NSDictionary
                let results = result!["results"] as! NSArray
                let dictAddressComponents = results[0] as! NSDictionary
//                let formattedAddress = dictAddressComponents["formatted_address"] as! String
//                self.autocompleteTextfield.text = formattedAddress
                let arrayAddressComponents = dictAddressComponents["address_components"] as! NSArray
                
                let dictAddress = NSMutableDictionary()
                
                
            
                
                for dict in arrayAddressComponents {
                    let dictTemp = dict as! NSDictionary
                    
                    let types = dictTemp["types"] as! NSArray
                    
                    if types.containsObject("street_number") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "Street")
                    }
                    if types.containsObject("route") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "Route")
                    }
                    if types.containsObject("locality") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "City")
                    }
                    if types.containsObject("administrative_area_level_1") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "State")
                    }
                    if types.containsObject("country") {
                        dictAddress.setObject(dictTemp["long_name"] as! String, forKey: "Country")
                    }
                    if types.containsObject("postal_code") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "Zip")
                    }
                }
                
                var address1 = ""
                
                if dictAddress["street"] as? String != nil && dictAddress["Route"] as? String != nil {
                    address1 = "\(dictAddress["Street"] as! String) \(dictAddress["Route"] as! String)"
                }
                else if dictAddress["street"] as? String != nil && dictAddress["Route"] as? String == nil {
                    address1 = "\(dictAddress["Street"] as! String)"
                }
                else if dictAddress["street"] as? String == nil && dictAddress["Route"] as? String != nil {
                    address1 = "\(dictAddress["Route"] as! String)"
                }
                
                var zip = "10075"
                if dictAddress["Zip"] != nil {
                    zip = dictAddress["Zip"] as! String
                }
                
                let city = dictAddress["City"] as! String
                let State = dictAddress["State"] as! String
                self.autocompleteTextfield.text = ("\(city), \(State)")
                let Country = dictAddress["Country"] as! String
                AppDelegate.returnAppDelegate().userProperty.setObject(address1, forKey: "address1")
                AppDelegate.returnAppDelegate().userProperty.setObject(zip, forKey: "zip")
                AppDelegate.returnAppDelegate().userProperty.setObject(city, forKey: "city")
                AppDelegate.returnAppDelegate().userProperty.setObject(State, forKey: "state")
                AppDelegate.returnAppDelegate().userProperty.setObject(Country, forKey: "country")
//
//                self.autocompleteTextfield.text = "\(dictAddress["City"] as! String), \(dictAddress["State"] as! String), \(dictAddress["Country"] as! String)"
//                let address = dictAddress["formatted_address"] as! String
//                self.autocompleteTextfield.text = address
                }
                catch {
                    
                }
            }
            else {
                
            }
        }
        dataTask.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    @IBAction func btnNext_Tapped(sender: AnyObject) {
        if self.detailController == nil {
            self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ucldetailVC") as? UCLDetailsViewController
            detailController?.detailType = "detail"
        }
        self.navigationController?.pushViewController(self.detailController!, animated: true)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    private func configureTextField(){
        autocompleteTextfield.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        autocompleteTextfield.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        autocompleteTextfield.autoCompleteCellHeight = 35.0
        autocompleteTextfield.maximumAutoCompleteCount = 20
        autocompleteTextfield.hidesWhenSelected = true
        autocompleteTextfield.hidesWhenEmpty = true
        autocompleteTextfield.enableAttributedText = true
        autocompleteTextfield.isFromMap = false
        autocompleteTextfield.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
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
            if text == "Don't see your address?" {
                //uclAddressVC
                if self?.addressController == nil {
                    self?.addressController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclAddressVC") as? AddressViewController
                }
                self!.navigationController?.pushViewController((self?.addressController)!, animated: true)
            }
            else {
                Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
                    if let coordinate = placemark?.location?.coordinate {
                        self?.autocompleteTextfield.resignFirstResponder()
                        let centerCoordinate = coordinate
                        AppDelegate.returnAppDelegate().userProperty.setObject(centerCoordinate.latitude, forKey: "propertyLatitude")
                        AppDelegate.returnAppDelegate().userProperty.setObject(centerCoordinate.longitude, forKey: "propertyLongitude")
                        self!.mapView.centerCoordinate = centerCoordinate
                        let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 5000, 5000)
                        self!.mapView.setRegion(region, animated: true)
                        
                        let annotaion = SimpleAnnotation(coordinate: centerCoordinate, title: "", subtitle: "")
                        self!.mapView.addAnnotation(annotaion)

                    }
                })
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
                                            locations.append(dict["description"] as! String)
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

extension UCLLocationViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "property"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            
        }
        else {
            anView!.annotation = annotation
        }
        
        return anView
        
    }
}
