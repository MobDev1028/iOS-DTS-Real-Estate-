//
//  detailActionsTableViewCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 31/10/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class detailActionsTableViewCell: UITableViewCell {

    @IBOutlet weak var btnDriveTo: UIButton!
    @IBOutlet weak var btnStreetView: UIButton!
    @IBOutlet weak var btnGetInfo: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        formateButton(btnApply)
        formateButton(btnShare)
        formateButton(btnDriveTo)
        formateButton(btnGetInfo)
        formateButton(btnStreetView)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension detailActionsTableViewCell {
    func formateButton(btn: UIButton) -> Void {
        btn.layer.cornerRadius = btn.frame.size.width / 2
        btn.layer.borderColor = UIColor.blackColor().CGColor
        btn.layer.borderWidth = 1.0
        btn.clipsToBounds = true
    }
}
