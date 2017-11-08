//
//  MenuViewController.swift
//  101Compaign-iOS
//
//  Created by Andy Nyberg on 04/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import MessageUI

class MenuViewController: UIViewController {
    
    @IBOutlet weak var lblBuildNumber: UILabel!
    @IBOutlet weak var tblMenu: UITableView!
    var items: NSArray!
    var items1: NSArray!
    var items2: NSArray!
    var presentedSection = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //side-purchase-credit
        
        view.backgroundColor = UIColor.blackColor()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(blurEffectView)
        
        items = [["icon": "account-gear.png", "title": "My Details"], ["icon": "account-gear.png", "title": "My Rent"], ["icon": "account-gear.png", "title": "My Search Agents"], ["icon": "account-gear.png", "title": "Ditch My Space"], ["icon": "account-gear.png", "title": "My Ditch"]];
        
        items1 = [["icon": "account-gear.png", "title": "Technical Support"], ["icon": "account-gear.png", "title": "Feedback"]];
        
        items2 = [["icon": "account-gear.png", "title": "Terms of Service"], ["icon": "account-gear.png", "title": "Privacy Policy"]];
        
        view.bringSubviewToFront(self.tblMenu)
        view.bringSubviewToFront(self.lblBuildNumber)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 50
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 50)
        let viewHeader = UIView(frame: frame)
        viewHeader.backgroundColor = UIColor.clearColor()
        return viewHeader
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.items.count
        }
        else if section == 1 {
            return self.items1.count
        }
        else {
            return self.items2.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuTableViewCell
        if indexPath.section == 0 {
            let dict = self.items[indexPath.row] as! NSDictionary
            cell.lblTitle.text = dict["title"] as? String
            cell.ivMenu.image = UIImage.init(named: (dict["icon"] as? String)!)
        }
        else if indexPath.section == 1 {
            let dict = self.items1[indexPath.row] as! NSDictionary
            cell.lblTitle.text = dict["title"] as? String
            cell.ivMenu.image = UIImage.init(named: (dict["icon"] as? String)!)
        }
        else {
            let dict = self.items2[indexPath.row] as! NSDictionary
            cell.lblTitle.text = dict["title"] as? String
            cell.ivMenu.image = UIImage.init(named: (dict["icon"] as? String)!)
        }
        //        cell.selectionStyle = .None
        let viewBG = UIView(frame: cell.contentView.bounds)
        viewBG.backgroundColor = UIColor(hexString: "00c9ff")
        cell.selectedBackgroundView = viewBG
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let revealController = self.revealViewController()
        
        if indexPath.row == AppDelegate.returnAppDelegate().presentedRow && indexPath.section == presentedSection {
            revealController.setFrontViewPosition(.Right, animated: true)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        let storyboard: UIStoryboard!
        
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var newFrontController: UIViewController!
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let accountVC = storyboard.instantiateViewControllerWithIdentifier("accountVC") as! AccountViewController
                accountVC.viewType = 0
                newFrontController = accountVC
                
            }
            else if indexPath.row == 1 {
                let paymentMethodVC = storyboard.instantiateViewControllerWithIdentifier("paymentMethodsVC") as! PaymentMethodsViewController
                newFrontController = paymentMethodVC
            }
            else if indexPath.row == 2 {
                let searchAgentVC = storyboard.instantiateViewControllerWithIdentifier("searchAgentsVC") as! SearchAgentsViewController
                newFrontController = searchAgentVC
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().userProperty = NSMutableDictionary()
                AppDelegate.returnAppDelegate().newlyCreatedPropertyId = 0
                AppDelegate.returnAppDelegate().isNewProperty = true
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("uclclassVC") as! UCLClassViewController
                controller.listType = "goal"
                controller.hideBackButton = true
                controller.hideSideButton = false
                newFrontController = controller
            }
            else {
               newFrontController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("myDitchVC") as! MyDitchViewController
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                
                newFrontController = storyboard.instantiateViewControllerWithIdentifier("supportVC")
            }
            else if indexPath.row == 1 {
                newFrontController = storyboard.instantiateViewControllerWithIdentifier("feedbackVC")
            }
            
        }
        else {
            if indexPath.row == 0 {
                newFrontController = storyboard.instantiateViewControllerWithIdentifier("tosVC")
            }
            else if indexPath.row == 1 {
                newFrontController = storyboard.instantiateViewControllerWithIdentifier("privacyVC")
            }
        }
        
        
        let navigationController = UINavigationController(rootViewController: newFrontController)
        navigationController.navigationBarHidden = true
        revealController.setFrontViewPosition(.Right, animated: true)
        revealController.setFrontViewController(navigationController, animated: true)
        //        revealController.pushFrontViewController(navigationController, animated: true)
        AppDelegate.returnAppDelegate().presentedRow = indexPath.row
        presentedSection = indexPath.section
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
