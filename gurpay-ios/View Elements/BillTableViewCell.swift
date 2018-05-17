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

    @IBOutlet weak var bgView: UIView!
    
    var bill: Bill? = nil {
        didSet {
            let nf = NumberFormatter()
            nf.maximumFractionDigits = 2;
            nf.minimumFractionDigits = 2;
            nf.minimumIntegerDigits = 1
            
            self.titleLabel.text = bill!.name;
            self.costAllocationLabel.text = "$" + nf.string(from: NSNumber(value: bill!.subtotal))! + "/" + nf.string(from: NSNumber(value: bill!.total))!;
            
            if (bill!.subtotal + 0.02) >= bill!.total
            {
                self.statusImageView.image = #imageLiteral(resourceName: "Checkmark")
            } else if bill!.date_paid == nil || bill!.date_paid! > bill!.date_due{
                self.statusImageView.image = #imageLiteral(resourceName: "Alert")
            } else {
                self.statusImageView.image = #imageLiteral(resourceName: "RedX")
            }
            
            self.dateDueLabel.text = Util.displayDate(date: bill!.date_due);
            self.dateReceivedLabel.text = Util.displayDate(date: bill!.date_assigned);
            if bill!.date_paid != nil {
                self.datePaidLabel.text = Util.displayDate(date: bill!.date_paid!);
            }
            else {
                self.datePaidLabel.text = "Not yet paid.";
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
    }

    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        bgView.layer.cornerRadius = 7
        bgView.layer.masksToBounds = false
        bgView.layer.shadowRadius = 3
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 2, height: 2)
        bgView.layer.shadowOpacity = 0.3
        //bgView.layer.shadowPath = UIBezierPath(rect: bgView.bounds)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     /*
        let v = UIView()
        v.backgroundColor = UIColor(red: 26/255, green: 130/255, blue: 41/255, alpha: 1);
        
        if(selected) {
            self.selectedBackgroundView = v;
        }
        else {
            //self.selectedBackgroundView?.backgroundColor = UIColor(red: 20/255, green: 108/255, blue: 42/255, alpha: 1)
        }*/
        // Configure the view for the selected state
    }
        
}
