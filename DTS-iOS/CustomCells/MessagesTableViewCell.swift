//
//  MessagesTableViewCell.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 20/05/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnProperty: UIButton!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var ivProperty: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
