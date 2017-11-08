//
//  UCLClassViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 14/07/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class UCLClassViewController: BaseViewController {

    @IBOutlet weak var ivHeaderLogo: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblClass: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    var listUCL: NSArray!
    var listType: String!
    var mainTitle: String!
    var hideBackButton: Bool!
    var hideSideButton: Bool!
    var controller: UCLClassViewController?
    var controller1: UCLLocationViewController?
    var detailController: UCLDetailsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if listType == "goal" {
            mainTitle = "Goal"
            listUCL = [["title": "Relocating"], ["title": "RentingOut"], ["title": "Ditching"]
            ]
        }
        else if listType == "time" {
            mainTitle = "Time Frame"
            listUCL = [["title": "ASAP"], ["title": "1-3 Months"], ["title": "3+ Months"]
            ]
        }
        else if listType == "class" {
            mainTitle = "What type of space do you want to list?"
            listUCL = [["title": "Entire Home", "desc": "Your entire home"], ["title": "Private Room", "desc": "A single room in your home"], ["title": "Shared Room", "desc": "A  couch, airbed, etc"]
            ]
        }
        else if listType == "type" {
            listUCL = [["title": "Apartment"], ["title": "House"], ["title": "Bed and Breakfast"]
            ]
        }


        tblClass.dataSource = self
        tblClass.delegate = self
        
        self.btnSideMenu.hidden = hideSideButton
        self.btnBack.hidden = hideBackButton
        
        self.ivHeaderLogo.hidden = true
        
        if self.hideBackButton == true {
            self.ivHeaderLogo.hidden = false
        }
        
        
        let revealController = revealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton_Tapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension UCLClassViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listUCL.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as! UCLCell
            cell.lblTitle.text = self.mainTitle
            cell.selectionStyle = .None
            return cell
        }
        
        if self.listType == "class" {
            let cell = tableView.dequeueReusableCellWithIdentifier("valueCell", forIndexPath: indexPath) as! UCLCell
            let dictClass = self.listUCL[indexPath.row - 1] as! NSDictionary
            cell.lblTitle.text = dictClass["title"] as? String
            cell.lblDescription.text = dictClass["desc"] as? String
            return cell
        }

        
        let cell = tableView.dequeueReusableCellWithIdentifier("valueCell1", forIndexPath: indexPath) as! UCLCell
        let dictClass = self.listUCL[indexPath.row - 1] as! NSDictionary
        cell.lblTitle.text = dictClass["title"] as? String
        return cell
        
    }
}

extension UCLClassViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let titleCellHeight = (AppDelegate.returnAppDelegate().window?.frame.size.height)! - 360
            return titleCellHeight
        }
        return 80
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var mTitle = ""
        if self.listType == "goal" {
            AppDelegate.returnAppDelegate().userProperty = NSMutableDictionary()
            if indexPath.row == 1 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Relocating", forKey: "goal")
                //mTitle = "Nice! What type of place is your entire home in?"
                
                self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclclassVC") as? UCLClassViewController
                controller!.listType = "time"
                controller!.mainTitle = mTitle
                controller?.hideBackButton = false
                controller?.hideSideButton = false
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            else if indexPath.row == 2 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Renting Out", forKey: "goal")
                //mTitle = "Nice! What type of place is your private room in?"
                self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclclassVC") as? UCLClassViewController
                controller!.listType = "class"
                controller!.mainTitle = mTitle
                controller?.hideBackButton = false
                controller?.hideSideButton = false
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Ditching", forKey: "goal")
                //mTitle = "Nice! What type of place is your shared space in?"
                
                self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclclassVC") as? UCLClassViewController
                controller!.listType = "time"
                controller!.mainTitle = mTitle
                controller?.hideBackButton = false
                controller?.hideSideButton = false
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            
        }
        if self.listType == "time" {
            if indexPath.row == 1 {
                AppDelegate.returnAppDelegate().userProperty.setObject("ASAP", forKey: "timeFrame")
                //mTitle = "Nice! What type of place is your entire home in?"
            }
            else if indexPath.row == 2 {
                AppDelegate.returnAppDelegate().userProperty.setObject("1-3 Months", forKey: "timeFrame")
                //mTitle = "Nice! What type of place is your private room in?"
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().userProperty.setObject("3+ Months", forKey: "timeFrame")
                //mTitle = "Nice! What type of place is your shared space in?"
            }
            AppDelegate.returnAppDelegate().uclTitle = "Lease"
            if self.detailController == nil {
                self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ucldetailVC") as? UCLDetailsViewController
                detailController?.detailType = "lease"
            }
            self.navigationController?.pushViewController(self.detailController!, animated: true)
        }
        else if self.listType == "class" {
            if indexPath.row == 1 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Entire Home", forKey: "uclClass")
                mTitle = "Nice! What type of place is your entire home in?"
            }
            else if indexPath.row == 2 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Private Room", forKey: "uclClass")
                mTitle = "Nice! What type of place is your private room in?"
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Shared Room", forKey: "uclClass")
                mTitle = "Nice! What type of place is your shared space in?"
            }
            self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclclassVC") as? UCLClassViewController
            controller!.listType = "type"
            controller!.mainTitle = mTitle
            controller?.hideBackButton = false
            controller?.hideSideButton = false
            self.navigationController?.pushViewController(controller!, animated: true)
        }
        else if self.listType == "type" {
            if indexPath.row == 1 {
                AppDelegate.returnAppDelegate().uclTitle = "Just a little more about your apartment..."
                self.mainTitle = "What city is your apartment located in?"
            }
            else if indexPath.row == 2 {
                AppDelegate.returnAppDelegate().uclTitle = "Just a little more about your house..."
                self.mainTitle = "What city is your house located in?"
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().uclTitle = "Just a little more about your bed and breakfast..."
                self.mainTitle = "What city is your bed and breakfast located in?"
            }
            AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType")
            if self.controller1 == nil {
                self.controller1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ucllocationVC") as? UCLLocationViewController
                controller?.hideBackButton = false
                controller?.hideSideButton = true
                self.controller1!.mainTitle = self.mainTitle
            }
            self.navigationController?.pushViewController(self.controller1!, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
