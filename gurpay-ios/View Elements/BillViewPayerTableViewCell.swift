//
//  ViewBillPayerTableViewCell.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 5/14/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class BillViewPayerTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    
    public var payer : Bill.UserPaid? {
        didSet {
            self.nameLabel.text = payer!.user.name
            self.statusLabel.text = payer!.paid == true ? "Paid" : "Unpaid"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
