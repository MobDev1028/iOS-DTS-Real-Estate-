//
//  SearchAgentsViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 09/01/2017.
//  Copyright © 2017 Rapidzz. All rights reserved.
//

import UIKit
import MBProgressHUD

class SearchAgentsViewController: UIViewController {

    @IBOutlet weak var tblSearchAgents: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    
    var searchAgents: [AnyObject] = []
    var hud: MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        let revealController = revealViewController()
        revealController.panGestureRecognizer().enabled = false
        revealController.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        
        self.tblSearchAgents.dataSource = self
        self.tblSearchAgents.delegate = self

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getSearchAgents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

extension SearchAgentsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchAgents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("agentCell", forIndexPath: indexPath) as! SearchAgentTableViewCell
        let dictSearchAgent = self.searchAgents[indexPath.row] as! [String: AnyObject]
        
        cell.lblTitle.text = dictSearchAgent["name"] as? String
        cell.lblDescription.text = dictSearchAgent["last_execution"] as? String
        
        cell.selectionStyle = .None
        return cell
    }
}

extension SearchAgentsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dictSearchAgent = self.searchAgents[indexPath.row] as! NSDictionary
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editSearchAgentVC") as! EditSearchAgentViewController
        controller.dictSearchAgent = dictSearchAgent
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchAgentsViewController {
    func getSearchAgents() -> Void {
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getsearchagents?token=\(token)")
        }
        
        self.hud.show(true)
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let result = json as? NSDictionary
                    
                    let isSuccess = Bool(result!["success"] as! Int)
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    
                    self.searchAgents = result!["data"] as! [AnyObject]
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tblSearchAgents.reloadData()
                    })
                    
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
