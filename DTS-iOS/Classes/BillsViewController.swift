//
//  BillsViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 18/01/2017.
//  Copyright © 2017 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD

class BillsViewController: UIViewController {
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var tblBills: UITableView!
    
    var bills: [AnyObject] = []
    var hud: MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        let revealController = revealViewController()
        revealController.panGestureRecognizer().enabled = false
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        self.tblBills.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension BillsViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bills.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dictBill = bills[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("billCell", forIndexPath: indexPath) as! BillTableViewCell
        cell.lblTItle.text = dictBill["description"] as? String
        cell.lblDescription.text = "$\(dictBill["amount"] as! String)"
        
        cell.selectionStyle = .None
        return cell
    }
}

extension BillsViewController {
    
}
