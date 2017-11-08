//
//  UCLTypeViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 14/07/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class UCLTypeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func btnApt_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ucllocationVC") as! UCLLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func btnHouse_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ucllocationVC") as! UCLLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnBB_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ucllocationVC") as! UCLLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBack_Tapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
