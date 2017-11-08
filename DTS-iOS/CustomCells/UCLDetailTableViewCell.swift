//
//  UCLDetailTableViewCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 31/07/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class UCLDetailTableViewCell: UITableViewCell {

    
    @IBOutlet weak var viewInner: UIView!
    @IBOutlet weak var lblButtonPlus: UIButton!
    @IBOutlet weak var lblButtonLess: UIButton!
    @IBOutlet weak var lblValude: UILabel!
    @IBOutlet weak var lblCaption: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
