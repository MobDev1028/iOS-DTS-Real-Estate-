//
//  BillTableViewCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 18/01/2017.
//  Copyright © 2017 Rapidzz. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTItle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
