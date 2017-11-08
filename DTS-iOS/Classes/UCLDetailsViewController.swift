//
//  UCLDetailsViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 14/07/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class UCLDetailsViewController: BaseViewController {

    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var tblDetail: UITableView!
    var mainTitle: String!
    var strGuests: String!
    var strBeds: String!
    var strBaths: String!
    @IBOutlet weak var btnDelete: UIButton!
    var photoController: UCLPhotosViewController?
    var detailType: String!
    var monthRemaining: String!
    var rateMonthlyRent: String!
    var securityDeposit: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblDetail.dataSource = self
        self.tblDetail.delegate = self
        strGuests = "1"
        strBeds = "1"
        strBaths = "1"
        
        monthRemaining = "1"
        rateMonthlyRent = "0"
        securityDeposit = "0"
        
        
        let revealController = revealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
//        self.tblDetail.estimatedRowHeight = 95;
//        self.tblDetail.rowHeight = UITableViewAutomaticDimension;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnDelete_Tapped(sender: AnyObject) {
        
    }
    @IBAction func btnNext_Tapped(sender: AnyObject) {
        if detailType == "lease" {
            AppDelegate.returnAppDelegate().userProperty.setObject(monthRemaining, forKey: "monthRemaining")
            AppDelegate.returnAppDelegate().userProperty.setObject(rateMonthlyRent, forKey: "rateMonthlyRent")
            AppDelegate.returnAppDelegate().userProperty.setObject(securityDeposit, forKey: "securityDeposits")
            
            if AppDelegate.returnAppDelegate().userProperty.objectForKey("goal") as! String == "Ditching" {
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclclassVC") as? UCLClassViewController
                controller!.listType = "class"
                controller?.hideBackButton = false
                controller?.hideSideButton = false
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            else if AppDelegate.returnAppDelegate().userProperty.objectForKey("goal") as! String == "Relocating" {
                //destinationVC
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("destinationVC") as? DestinationViewController
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            
            
        }
        else {
            AppDelegate.returnAppDelegate().userProperty.setObject(strGuests, forKey: "guests")
            AppDelegate.returnAppDelegate().userProperty.setObject(strBeds, forKey: "beds")
            AppDelegate.returnAppDelegate().userProperty.setObject(strBaths, forKey: "baths")
            
            if self.photoController == nil {
                self.photoController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclphotosVC") as? UCLPhotosViewController
            }
            
            self.navigationController?.pushViewController(self.photoController!, animated: true)
        }
        
        
    }
    @IBAction func btnLess_Tapped(sender: AnyObject) {
        let btn = sender as! UIButton
        let cell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: btn.tag, inSection: 0)) as! UCLDetailTableViewCell
        if detailType == "lease" {
            if btn.tag == 1 {
                var guests = Int(monthRemaining)
                if guests! > 1 {
                    guests! = guests! - 1
                    cell.lblValude.text = String(guests!)
                    monthRemaining = cell.lblValude.text!
                }
            }
            else if btn.tag == 2 {
                var beds = Int(rateMonthlyRent)
                if beds! > 0 {
                    beds! = beds! - 250
                    cell.lblValude.text = String(beds!)
                    rateMonthlyRent = cell.lblValude.text!
                }
            }
            else {
                var baths = Int(securityDeposit)
                if baths! > 0 {
                    baths! = baths! - 250
                    cell.lblValude.text = String(baths!)
                    securityDeposit = cell.lblValude.text!
                }
            }
        }
        else {
            if btn.tag == 1 {
                var guests = Int(strGuests)
                if guests! > 1 {
                    guests! = guests! - 1
                    cell.lblValude.text = String(guests!)
                    strGuests = cell.lblValude.text!
                }
            }
            else if btn.tag == 2 {
                var beds = Int(strBeds)
                if beds! > 1 {
                    beds! = beds! - 1
                    cell.lblValude.text = String(beds!)
                    strBeds = cell.lblValude.text!
                }
            }
            else {
                var baths = Int(strBaths)
                if baths! > 1 {
                    baths! = baths! - 1
                    cell.lblValude.text = String(baths!)
                    strBeds = cell.lblValude.text!
                }
            }
        }
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnPlus_Tapped(sender: AnyObject) {
        let btn = sender as! UIButton
        let cell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: btn.tag, inSection: 0)) as! UCLDetailTableViewCell
        
        if detailType == "lease" {
            if btn.tag == 1 {
                var guests = Int(monthRemaining)
                
                guests! = guests! + 1
                cell.lblValude.text = String(guests!)
                monthRemaining = cell.lblValude.text!
                
            }
            else if btn.tag == 2 {
                var beds = Int(rateMonthlyRent)
                
                beds! = beds! + 250
                cell.lblValude.text = String(beds!)
                rateMonthlyRent = cell.lblValude.text!
                
            }
            else {
                var baths = Int(securityDeposit)
                
                baths! = baths! + 250
                cell.lblValude.text = String(baths!)
                securityDeposit = cell.lblValude.text!
                
            }
        }
        else {
            if btn.tag == 1 {
                var guests = Int(strGuests)
                
                guests! = guests! + 1
                cell.lblValude.text = String(guests!)
                strGuests = cell.lblValude.text!
                
            }
            else if btn.tag == 2 {
                var beds = Int(strBeds)
                
                beds! = beds! + 1
                cell.lblValude.text = String(beds!)
                strBeds = cell.lblValude.text!
                
            }
            else {
                var baths = Int(strBaths)
                
                baths! = baths! + 1
                cell.lblValude.text = String(baths!)
                strBaths = cell.lblValude.text!
                
            }

        }
        
    }


}

extension UCLDetailsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if detailType == "lease" {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as! UCLCell
                cell.lblTitle.text = AppDelegate.returnAppDelegate().uclTitle
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Months Remaining"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblValude.text = monthRemaining
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").CGColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSizeMake(0, 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Rate (monthly rent)"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblValude.text = rateMonthlyRent
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").CGColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSizeMake(0, 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .None
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Security Deposit"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblValude.text = securityDeposit
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").CGColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSizeMake(0, 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .None
                return cell
            }
        }
        else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as! UCLCell
                cell.lblTitle.text = AppDelegate.returnAppDelegate().uclTitle
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Max Guests"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblValude.text = strGuests
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").CGColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSizeMake(0, 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Beds"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblValude.text = strBeds
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").CGColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSizeMake(0, 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .None
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Baths"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), forControlEvents: .TouchUpInside)
                cell.lblValude.text = strBaths
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").CGColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSizeMake(0, 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .None
                return cell
            }
        }
        
    }
}

extension UCLDetailsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let titleCellHeight = (AppDelegate.returnAppDelegate().window?.frame.size.height)! - 425
            return titleCellHeight
        }
        return 80
    }
    
}



