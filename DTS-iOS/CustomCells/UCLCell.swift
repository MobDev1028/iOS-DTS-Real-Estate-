//
//  UCLCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 28/07/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class UCLCell: UITableViewCell {

    @IBOutlet weak var lblDescription: UILabel!
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
