//
//  BillTableViewCell.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/28/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var costAllocationLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var dateDueLabel: UILabel!
    
    @IBOutlet weak var dateReceivedLabel: UILabel!
    @IBOutlet weak var datePaidLabel: UILabel!

    var bill: Bill? = nil {
        didSet {
            self.titleLabel.text = bill!.name;
            self.costAllocationLabel.text = "TODO";
            //self.statusImageView = ??
            self.dateDueLabel.text = Util.displayDate(date: bill!.date_due);
            self.dateReceivedLabel.text = Util.displayDate(date: bill!.date_assigned);
            if bill!.date_paid != nil {
                self.datePaidLabel.text = Util.displayDate(date: bill!.date_paid!);
            }
            else {
                self.datePaidLabel.text = "Not yet pad.";
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
        let v = UIView()
        v.backgroundColor = UIColor(red: 26/255, green: 130/255, blue: 41/255, alpha: 1);
        
        if(selected) {
            self.selectedBackgroundView = v;
        }
        else {
            //self.selectedBackgroundView?.backgroundColor = UIColor(red: 20/255, green: 108/255, blue: 42/255, alpha: 1)
        }
        // Configure the view for the selected state
    }
        
}
