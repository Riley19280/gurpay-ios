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
    @IBOutlet weak var bgView: UIView!
    
    
    public var payer : UserPaid? {
        didSet {
            self.nameLabel.text = payer!.user.name
            self.statusLabel.text = payer!.paid == true ? "Paid" : "Unpaid"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
/*
        bgView.layer.masksToBounds = false
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 1, height: 1)
        bgView.layer.shadowOpacity = 0.3
        self.backgroundColor = UIColor.clear
    */
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
