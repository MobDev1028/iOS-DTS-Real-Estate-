//
//  FollowupTableViewCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 13/06/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class FollowupTableViewCell: UITableViewCell {

    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
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
