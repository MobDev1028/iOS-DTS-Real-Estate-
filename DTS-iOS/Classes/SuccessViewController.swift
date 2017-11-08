//
//  SuccessViewController.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 26/12/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    @IBOutlet weak var lblSuccessMessage: UILabel!
    @IBOutlet weak var btnSideMenu: UIButton!
    var successMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if successMessage != nil {
            self.lblSuccessMessage.text = successMessage
        }
        
        self.performSelector(#selector(SuccessViewController.loadRootViewController), withObject: nil, afterDelay: 5)

    }
    
    func loadRootViewController() -> Void {
        AppDelegate.returnAppDelegate().UpdateRootVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
