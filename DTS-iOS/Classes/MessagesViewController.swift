//
//  MessagesViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 19/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit


import MBProgressHUD

class MessagesViewController: BaseViewController {

    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var view9: UIView!
    @IBOutlet weak var view8: UIView!
    @IBOutlet weak var view7: UIView!
    @IBOutlet weak var view6: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var tblMessages: UITableView!
    var messages: NSMutableArray = NSMutableArray()
    var hud: MBProgressHUD!
    var dictSelectedMessage: NSDictionary!
    var dictSelectedProperty: NSDictionary!
    var dictMessageData: NSDictionary!
    var refreshControl: UIRefreshControl!
    var parents: NSArray!
    var total = 0
    var dataSource: [Parent]!
    var isInquired: Bool!
    /// Define wether can exist several cells expanded or not.
    let numberOfCellsExpanded: NumberOfCellExpanded = .One
    
    /// Constant to define the values for the tuple in case of not exist a cell expanded.
    let NoCellExpanded = (-1, -1)
    
    /// The index of the last cell expanded and its parent.
    var lastCellExpanded : (Int, Int)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Messages"
//        self.tblMessages.editing = true
        self.hud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.hud)
        
        AppDelegate.returnAppDelegate().isBack = false
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(MessagesViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tblMessages.addSubview(refreshControl)
        self.btnAccount.hidden = true
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            self.btnAccount.hidden = false
            
            let revealController = revealViewController()
//            revealController.panGestureRecognizer()
            revealController.tapGestureRecognizer()
            
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: .TouchUpInside)
        }
        
//        if let savedParents = Utils.unarchiveDataForKey("savedParents") {
//            self.parents = savedParents
//            self.setInitialDataSource(numberOfRowParents: self.parents.count, numberOfRowChildPerParent: 3)
//            self.lastCellExpanded = self.NoCellExpanded
//            self.tblMessages.reloadData()
//        }
//        else {
//            self.hud.show(true)
//            self.messages = NSMutableArray()
//            if AppDelegate.returnAppDelegate().isBack == false {
//                self.getMessages()
//            }
//            else {
//                self.getMessagesWhenBack()
//            }
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        //self.hud.show(true)
//        self.messages = NSMutableArray()
//        if AppDelegate.returnAppDelegate().isBack == false {
//            self.hud.show(true)
//            self.getMessages()
//        }
//        else {
//            self.getMessagesWhenBack()
//        }
        
        if AppDelegate.returnAppDelegate().isBack == true {
            self.messages = NSMutableArray()
            self.getMessagesWhenBack()
        }
        else {
            if let savedParents = Utils.unarchiveDataForKey("savedParents") {
                self.parents = savedParents
                self.setInitialDataSource(numberOfRowParents: self.parents.count, numberOfRowChildPerParent: 3)
                self.lastCellExpanded = self.NoCellExpanded
                self.tblMessages.reloadData()
            }
            else {
                self.messages = NSMutableArray()
                self.hud.show(true)
                self.getMessages()
            }
        }

    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.returnAppDelegate().isBack = true
    }
    
    func deletParentAndChildrenMessages(tableView: UITableView, withParent parent: Int, andIndexPath indexPath: NSIndexPath) -> Void {
        let dictMessage = self.dataSource[parent].dict as NSDictionary
        let msgID = String(dictMessage["id"] as! Int)
        //self.dataSource[parent].childs.removeObjectAtIndex(indexPath.row - actualPosition - 1)
        
        
        
        self.total = self.total - (1 + self.dataSource[parent].childs.count)
        var arrayIndexPaths = [NSIndexPath]()
        arrayIndexPaths.append(indexPath)
        for i in 1...self.dataSource[parent].childs.count {
            let childIndedPath = NSIndexPath(forRow: indexPath.row + i, inSection: 0)
            arrayIndexPaths.append(childIndedPath)
        }
        
        
        self.dataSource.removeAtIndex(parent)
        if let tempParents = self.parents.mutableCopy() as? NSMutableArray {
            
            tempParents.removeObjectAtIndex(parent)
            self.parents = tempParents.copy() as! NSArray
        }
        
        Utils.archiveArray(self.parents, forKey: "savedParents")
        
        tableView.deleteRowsAtIndexPaths(arrayIndexPaths, withRowAnimation: .Automatic)
       // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/updatemsg?token=\(token)&msg_id=\(msgID)&action=archive")
        }
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    _ = json as? NSDictionary
                    
                    
                }
                catch {
                    
                }
            }
            else {
            
            }
        }
        dataTask.resume()
        
    }
    
    func deleteSingleRowOfTable(tableView: UITableView, withParent parent: Int, andIndexPath indexPath: NSIndexPath) -> Void {
        let dictMessage = self.dataSource[parent].dict as NSDictionary
        let msgID = String(dictMessage["id"] as! Int)
        //self.dataSource[parent].childs.removeObjectAtIndex(indexPath.row - actualPosition - 1)
        
        self.dataSource.removeAtIndex(parent)
        if let tempParents = self.parents.mutableCopy() as? NSMutableArray {
            tempParents.removeObjectAtIndex(parent)
            self.parents = tempParents.copy() as! NSArray
        }
        
        
        Utils.archiveArray(self.parents, forKey: "savedParents")
        self.total = self.total - 1
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        var strURL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/updatemsg?token=\(token)&msg_id=\(msgID)&action=archive")
        }
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    _ = json as? NSDictionary
                    
                    
                }
                catch {
                    
                }
            }
            else {
                
            }
        }
        dataTask.resume()

    }
    
    func refresh(sender:AnyObject) {
//        self.getMessagesWhenBack()
        self.getMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnProperty_Tapped(sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let btn = sender as! UIButton
        let (parent, _, _) = self.findParent(btn.tag)
        dictSelectedProperty = self.dataSource[parent].dictPorperty as NSDictionary
        self.performSegueWithIdentifier("messagesToPD", sender: self)
    }
    @IBAction func btnAction_Tapped(sender: AnyObject) {
        let btn = sender as! UIButton
        if btn.tag > self.total {
            return
        }
        self.isInquired = false
        let (parent, _, _) = self.findParent(btn.tag)
        dictSelectedMessage = self.dataSource[parent].dict as NSDictionary
        dictSelectedProperty = self.dataSource[parent].dictPorperty as NSDictionary
        if dictSelectedMessage["type"] as! String == "doc_sign" {
            self.performSegueWithIdentifier("messageToDoc", sender: self)
        }
        else if dictSelectedMessage["type"] as! String == "demo" {
            self.performSegueWithIdentifier("messagesToDemo", sender: self)
        }
        else if dictSelectedMessage["type"] as! String == "inquire" {
            self.isInquired = true
            self.performSegueWithIdentifier("messageToFollowUp", sender: self)
        }
        else {
            self.performSegueWithIdentifier("messageToFollowUp", sender: self)
        }
    }
    
    
    func getMessagesWhenBack() -> Void {
        var strURL = "https://api.ditchthe.space/api/getmsg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIxLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzkxMSwiZXhwIjoxNTU3MjQ1OTExLCJuYmYiOjE0NjM5MzM5MTEsImp0aSI6IjdkMGYzNWFiNGM0MzBjNjQ0YWJiN2RlODU0YzAwNDA5In0.5COr5Q6H6FGeVVaTJPHHfZuFZg0A8caLI5ZYCM_x4T8&type=thread&paginated=0&page=1&archived=0"
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getmsg?token=\(token)&type=thread&paginated=0&page=1&archived=0")
        }
        
        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let tempData = json as? NSDictionary
                
                let isSuccess = Bool(tempData!["success"] as! Int)
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.parents =  tempData!["data"]!["thread"] as! NSArray
                Utils.archiveArray(self.parents, forKey: "savedParents")
                self.setInitialDataSource(numberOfRowParents: self.parents.count, numberOfRowChildPerParent: 3)
                self.lastCellExpanded = self.NoCellExpanded
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tblMessages.reloadData()
                        if (AppDelegate.returnAppDelegate().selectedParent > -1 && AppDelegate.returnAppDelegate().selectedIndex > -1) {
                            self.tblMessages.beginUpdates()
                            self.updateCells(AppDelegate.returnAppDelegate().selectedParent, index: AppDelegate.returnAppDelegate().selectedIndex)
                            self.tblMessages.endUpdates()
                        }
                        self.refreshControl.endRefreshing()
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
    
    func getMessages() -> Void {
        var strURL = "https://api.ditchthe.space/api/getmsg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIxLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzkxMSwiZXhwIjoxNTU3MjQ1OTExLCJuYmYiOjE0NjM5MzM5MTEsImp0aSI6IjdkMGYzNWFiNGM0MzBjNjQ0YWJiN2RlODU0YzAwNDA5In0.5COr5Q6H6FGeVVaTJPHHfZuFZg0A8caLI5ZYCM_x4T8&type=thread&paginated=0&page=1&archived=0"
        
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            strURL = ("https://api.ditchthe.space/api/getmsg?token=\(token)&type=thread&paginated=0&page=1&archived=0")
        }

        
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                do {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hud.hide(true)
                    })
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let tempData = json as? NSDictionary
                
                let isSuccess = Bool(tempData!["success"] as! Int)
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.parents =  tempData!["data"]!["thread"] as! NSArray
                
                Utils.archiveArray(self.parents, forKey: "savedParents")
                
                self.setInitialDataSource(numberOfRowParents: self.parents.count, numberOfRowChildPerParent: 3)
                self.lastCellExpanded = self.NoCellExpanded

                    dispatch_async(dispatch_get_main_queue(), {
                        self.tblMessages.reloadData()
                        
                        
                        self.refreshControl.endRefreshing()
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
    
    func FadeOut() -> Void {
        UIView.animateWithDuration(0.15, animations: {
            self.view1.alpha = 0
            self.view.layoutIfNeeded()
        }) { (finished: Bool) in
            self.view1.hidden = true
            
            UIView.animateWithDuration(0.15, animations: {
                self.view2.alpha = 0
                self.view.layoutIfNeeded()
            }) { (finished: Bool) in
                self.view2.hidden = true
                UIView.animateWithDuration(0.15, animations: {
                    self.view3.alpha = 0
                    self.view.layoutIfNeeded()
                }) { (finished: Bool) in
                    self.view3.hidden = true
                    UIView.animateWithDuration(0.15, animations: {
                        self.view4.alpha = 0
                        self.view.layoutIfNeeded()
                    }) { (finished: Bool) in
                        self.view4.hidden = true
                        UIView.animateWithDuration(0.15, animations: {
                            self.view5.alpha = 0
                            self.view.layoutIfNeeded()
                        }) { (finished: Bool) in
                            self.view5.hidden = true
                            UIView.animateWithDuration(0.15, animations: {
                                self.view6.alpha = 0
                                self.view.layoutIfNeeded()
                            }) { (finished: Bool) in
                                self.view6.hidden = true
                                UIView.animateWithDuration(0.15, animations: {
                                    self.view7.alpha = 0
                                    self.view.layoutIfNeeded()
                                }) { (finished: Bool) in
                                    self.view7.hidden = true
                                    UIView.animateWithDuration(0.15, animations: {
                                        self.view8.alpha = 0
                                        self.view.layoutIfNeeded()
                                    }) { (finished: Bool) in
                                        self.view8.hidden = true
                                        UIView.animateWithDuration(0.15, animations: {
                                            self.view9.alpha = 0
                                            self.view.layoutIfNeeded()
                                        }) { (finished: Bool) in
                                            self.view9.hidden = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }

    }
    
    
    private func setInitialDataSource(numberOfRowParents parents: Int, numberOfRowChildPerParent childs: Int) {
        
        // Set the total of cells initially.
        self.total = parents
        
        
        let data = [Parent](count: parents, repeatedValue: Parent(state: .Collapsed, childs: [], dict: nil, dictPorperty: nil))
        
        dataSource = data.enumerate().map({ (index: Int, element: Parent) -> Parent in
            
            var newElement = element
            newElement.dictPorperty = self.parents[index] as! NSDictionary
            let tempArray = self.parents[index]["msgs"] as! NSArray
            let msgs = NSMutableArray()
            
    
            //for i in tem...self.dataSource[parent].childs.count
            /*if tempArray.count > 0 {
                for i in (0...(tempArray.count-1)).reverse() {
//                    print(i)
                    if let dictMsg = tempArray[i] as? NSDictionary {
                        if dictMsg["type"] as? String != nil  {
                            msgs.addObject(dictMsg)
                        }
                    }
                }
            }*/
            
            
            
            for dictMsg in tempArray {
                if dictMsg as? NSDictionary != nil {
                    if dictMsg["type"] as? String != nil  {
                        msgs.addObject(dictMsg)
                    }
                }

            }
            
            let dictFirstMessage = msgs.firstObject as! NSDictionary
            newElement.dict = dictFirstMessage
            
            newElement.childs = msgs
            
            return newElement
        })
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messageToFollowUp" {
            let controller = segue.destinationViewController as! FollowUpViewController
            controller.dictSelectedMessage = self.dictSelectedMessage
            controller.dictProperty = self.dictSelectedProperty
            controller.isInquired = self.isInquired
            
        }
        else if segue.identifier == "messageToDoc" {
            let controller = segue.destinationViewController as! DocMessageViewController
            controller.dictSelectedMessage = self.dictSelectedMessage
            controller.isFromSignature = false
            controller.dictProperty = self.dictSelectedProperty
        }
        else if segue.identifier == "messagesToDemo" {
            let controller = segue.destinationViewController as! DemoMessageViewController
            controller.dictSelectedMessage = self.dictSelectedMessage
            controller.dictProperty = self.dictSelectedProperty
        }
        else if segue.identifier == "messagesToPD" {
            let controller = segue.destinationViewController as! PropertyDetailViewController
            controller.propertyID = String(dictSelectedProperty["id"] as! Int)
            controller.dictProperty = dictSelectedProperty
            controller.isFromMainView = true
        }
    }
    
    
    
    /**
     Expand the cell at the index specified.
     
     - parameter index: The index of the cell to expand.
     */
    private func expandItemAtIndex(index : Int, parent: Int) {
        
        
        AppDelegate.returnAppDelegate().selectedParent = parent
        AppDelegate.returnAppDelegate().selectedIndex = index
        // the data of the childs for the specific parent cell.
        let currentSubItems = self.dataSource[parent].childs
        
        // update the state of the cell.
        self.dataSource[parent].state = .Expanded
        
        // position to start to insert rows.
        var insertPos = index + 1
        
        let indexPaths = (0..<currentSubItems.count).map { _ -> NSIndexPath in
            let indexPath = NSIndexPath(forRow: insertPos, inSection: 0)
            insertPos += 1
            return indexPath
        }
        
        // insert the new rows
        self.tblMessages.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        
        // update the total of rows
        self.total += currentSubItems.count
    }
    
    /**
     Collapse the cell at the index specified.
     
     - parameter index: The index of the cell to collapse
     */
    private func collapseSubItemsAtIndex(index : Int, parent: Int) {
        
        var indexPaths = [NSIndexPath]()
        
        let numberOfChilds = self.dataSource[parent].childs.count
        
        // update the state of the cell.
        self.dataSource[parent].state = .Collapsed
        
        guard index + 1 <= index + numberOfChilds else { return }
        
        // create an array of NSIndexPath with the selected positions
        indexPaths = (index + 1...index + numberOfChilds).map { NSIndexPath(forRow: $0, inSection: 0)}
        
        // remove the expanded cells
        self.tblMessages.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        
        // update the total of rows
        self.total -= numberOfChilds
    }
    
    /**
     Update the cells to expanded to collapsed state in case of allow severals cells expanded.
     
     - parameter parent: The parent of the cell
     - parameter index:  The index of the cell.
     */
    private func updateCells(parent: Int, index: Int) {
        
        switch (self.dataSource[parent].state) {
            
        case .Expanded:
            self.collapseSubItemsAtIndex(index, parent: parent)
            self.lastCellExpanded = NoCellExpanded
            AppDelegate.returnAppDelegate().selectedParent = -1
            AppDelegate.returnAppDelegate().selectedIndex = -1
            
        case .Collapsed:
            switch (numberOfCellsExpanded) {
            case .One:
                // exist one cell expanded previously
                if self.lastCellExpanded != NoCellExpanded {
                    
                    let (indexOfCellExpanded, parentOfCellExpanded) = self.lastCellExpanded
                    
                    self.collapseSubItemsAtIndex(indexOfCellExpanded, parent: parentOfCellExpanded)
                    
                    // cell tapped is below of previously expanded, then we need to update the index to expand.
                    if parent > parentOfCellExpanded {
                        let newIndex = index - self.dataSource[parentOfCellExpanded].childs.count
                        self.expandItemAtIndex(newIndex, parent: parent)
                        self.lastCellExpanded = (newIndex, parent)
                    }
                    else {
                        self.expandItemAtIndex(index, parent: parent)
                        self.lastCellExpanded = (index, parent)
                    }
                }
                else {
                    self.expandItemAtIndex(index, parent: parent)
                    self.lastCellExpanded = (index, parent)
                }
            case .Several:
                self.expandItemAtIndex(index, parent: parent)
            }
        }
    }
    
    /**
     Find the parent position in the initial list, if the cell is parent and the actual position in the actual list.
     
     - parameter index: The index of the cell
     
     - returns: A tuple with the parent position, if it's a parent cell and the actual position righ now.
     */
    private func findParent(index : Int) -> (parent: Int, isParentCell: Bool, actualPosition: Int) {
        
        var position = 0, parent = 0
        guard position < index else { return (parent, true, parent) }
        
        var item = self.dataSource[parent]
        
        repeat {
            
            switch (item.state) {
            case .Expanded:
                position += item.childs.count + 1
            case .Collapsed:
                position += 1
            }
            
            parent += 1
            
            // if is not outside of dataSource boundaries
            if parent < self.dataSource.count {
                item = self.dataSource[parent]
            }
            
        } while (position < index)
        
        // if it's a parent cell the indexes are equal.
        if position == index {
            return (parent, position == index, position)
        }
        
        item = self.dataSource[parent - 1]
        return (parent - 1, position == index, position - item.childs.count - 1)
    }
    
    @IBAction func btnAccount_Tapped(sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
        
}

extension MessagesViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.total
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let (parent, isParentCell, actualPosition) = self.findParent(indexPath.row)
        
        if !isParentCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("childCell", forIndexPath: indexPath) as! MessagesTableViewCell
            let dictMessage = self.dataSource[parent].childs[indexPath.row - actualPosition - 1] as! NSDictionary
            cell.selectionStyle = .None
            if dictMessage["type"] as! String == "doc_sign" {
                cell.lblSubject.text = "SIGN LEASE"
                
            }
            else if dictMessage["type"] as! String == "follow_up" {
                cell.lblSubject.text = "FOLLOW UP"
            }
            else if dictMessage["type"] as! String == "demo" {
                
                cell.lblSubject.text = "ON-SITE DEMO"
            }
            else if dictMessage["type"] as! String == "inquire" {
                 cell.lblSubject.text = "INQUIRED"
                
            }
            else {
                cell.lblSubject.text = dictMessage["type"]!.uppercaseString
            }
            
            cell.lblDuration.text = dictMessage["updated_at_formatted"] as? String
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("messagesCell", forIndexPath: indexPath) as! MessagesTableViewCell
            let dictMessage = self.dataSource[parent].dict as NSDictionary
            let dictProperty = self.dataSource[parent].dictPorperty as NSDictionary
            cell.selectionStyle = .None
            cell.btnProperty.tag = indexPath.row
            cell.btnProperty.addTarget(self, action: #selector(MessagesViewController.btnProperty_Tapped(_:)), forControlEvents: .TouchUpInside)
            cell.btnAction.tag = indexPath.row
            cell.btnAction.addTarget(self, action: #selector(MessagesViewController.btnAction_Tapped(_:)), forControlEvents: .TouchUpInside)
            
            cell.lblSubject.numberOfLines = 0;
//            cell.lblSubject.textAlignment = .Center
            cell.lblSubject.textColor = UIColor(hexString: "ff0500")
            if dictMessage["type"] as! String == "doc_sign" {
                cell.lblSubject.text = "SIGN LEASE"
                
                if dictMessage["declined"] as! Int != 0 {
                    cell.btnAction.setTitle("DECLINED", forState: .Normal)
                }
                else if dictMessage["doc"] as? NSDictionary != nil {
                    if dictMessage["doc"]!["signed"] as! Int == 0 {
                        cell.btnAction.setTitle("SIGN DOC", forState: .Normal)
                    }
                    else {
                        cell.btnAction.setTitle("SIGNED", forState: .Normal)
                    }
                }
                else {
                    cell.btnAction.setTitle("SIGN DOC", forState: .Normal)
                }
                
            }
            else if dictMessage["type"] as! String == "follow_up" {
                cell.lblSubject.text = "FOLLOW UP"
                if dictMessage["replies"] as! Int == 0 {
                    cell.btnAction.setTitle("FOLLOW UP", forState: .Normal)
                }
                else {
                    cell.btnAction.setTitle("REPLIED", forState: .Normal)
                }
            }
            else if dictMessage["type"] as! String == "demo" {
                cell.lblSubject.text = "ON-SITE DEMO"
                if dictMessage["accepted"] as! Int != 0 {
                    cell.btnAction.setTitle("ACCEPTED", forState: .Normal)
                }
                else if dictMessage["declined"] as! Int != 0 {
                    cell.btnAction.setTitle("DECLINED", forState: .Normal)
                }
                else {
                    cell.btnAction.setTitle("DEMO", forState: .Normal)
                }
            }
            else if dictMessage["type"] as! String == "inquire" {
                cell.lblSubject.text = "INQUIRED"
                cell.lblSubject.textColor = UIColor(hexString: "02ce37")
                if dictMessage["replies"] as! Int == 0 {
                    cell.btnAction.setTitle("VIEW", forState: .Normal)
                }
                else {
                    cell.btnAction.setTitle("VIEW", forState: .Normal)
                }
                
            }
            else {
                cell.lblSubject.text = dictMessage["type"]!.uppercaseString
                if dictMessage["replies"] as! Int == 0 {
                    cell.btnAction.setTitle("VIEW", forState: .Normal)
                }
                else {
                    cell.btnAction.setTitle("REPLIED", forState: .Normal)
                }
            }
            
            
            
//            cell.lblAddress.textAlignment = .Center
            cell.lblDuration.text = dictMessage["updated_at_formatted"] as? String
            let address1 = dictProperty["address1"] as! String
            let city = dictProperty["city"] as! String
            let state = dictProperty["state_or_province"] as! String
            let zip = dictProperty["zip"] as! String
            
            cell.lblAddress.text = address1
            cell.lblCountry.text = "\(city), \(state) \(zip)"
            
            let imgURL = dictProperty["img_url"]!["sm"] as! String
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                cell.ivProperty.image = image
            })
            
            return cell

        }

        
        
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Archive"
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let (_, isParentCell, _) = self.findParent(indexPath.row)
        if !isParentCell {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.tblMessages.beginUpdates()
        if editingStyle == .Delete {
            
            let (parent, isParentCell, _) = self.findParent(indexPath.row)
            
            if isParentCell {
                
                switch self.dataSource[parent].state {
                case .Collapsed:
                    self.deleteSingleRowOfTable(tableView, withParent: parent, andIndexPath: indexPath)
                case .Expanded:
                    self.updateCells(parent, index: indexPath.row)
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                        self.deleteSingleRowOfTable(tableView, withParent: parent, andIndexPath: indexPath)
                    })
                }
            }
            
        }
        self.tblMessages.endUpdates()
    }
}


extension MessagesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let (parent, isParentCell, actualPosition) = self.findParent(indexPath.row)
        
        if isParentCell {
        
        }
        else {
            
            self.isInquired = false
            dictSelectedMessage = self.dataSource[parent].childs[indexPath.row - actualPosition - 1] as! NSDictionary
            dictSelectedProperty = self.dataSource[parent].dictPorperty as NSDictionary
            if dictSelectedMessage["type"] as! String == "doc_sign" {
                self.performSegueWithIdentifier("messageToDoc", sender: self)
            }
            else if dictSelectedMessage["type"] as! String == "demo" {
                self.performSegueWithIdentifier("messagesToDemo", sender: self)
            }
            else if dictSelectedMessage["type"] as! String == "inquire" {
                self.isInquired = true
                self.performSegueWithIdentifier("messageToFollowUp", sender: self)
            }
            else {
                self.performSegueWithIdentifier("messageToFollowUp", sender: self)
            }
            
            return

        }
        
        
        self.tblMessages.beginUpdates()
        self.updateCells(parent, index: indexPath.row)
        self.tblMessages.endUpdates()
        

    }
    
    
}
