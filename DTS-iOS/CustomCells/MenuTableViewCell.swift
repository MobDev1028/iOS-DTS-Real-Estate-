//
//  MenuTableViewCell.swift
//  101Compaign-iOS
//
//  Created by Andy Nyberg on 04/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var viewSeprator: UIView!
    @IBOutlet weak var ivMenu: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
