//
//  SelectPayersTableViewCell.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 5/10/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class SelectPayersTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User? {
        didSet {
             nameLabel.text = user?.name;
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
