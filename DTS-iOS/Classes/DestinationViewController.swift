//
//  DestinationViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 28/11/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class DestinationViewController: UIViewController {
    
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    private var responseData:NSMutableData?
    private var dataTask:NSURLSessionDataTask?
    private let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    private let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let revealController = revealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)

        configureTextField()
        handleTextFieldInterfaces()
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty.setObject("Ditching", forKey: "goal")
        //mTitle = "Nice! What type of place is your shared space in?"
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclclassVC") as? UCLClassViewController
        controller!.listType = "class"
        controller?.hideBackButton = false
        controller?.hideSideButton = false
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension DestinationViewController {
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
            AppDelegate.returnAppDelegate().userProperty.setObject(text, forKey: "destinationRegion")
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

extension DestinationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
