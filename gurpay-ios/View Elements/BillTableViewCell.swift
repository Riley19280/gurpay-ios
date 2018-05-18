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
    @IBOutlet weak var ownerLabel: UILabel!
    
    @IBOutlet weak var dateReceivedLabel: UILabel!
    @IBOutlet weak var datePaidLabel: UILabel!

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var rightStack: UIStackView!
    @IBOutlet weak var statusOverlay: UIImageView!
    @IBOutlet weak var statusOverlayHeightConstraint: NSLayoutConstraint!
    
    var bill: Bill? = nil {
        didSet {
            configure();
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
   
        statusOverlay.setNeedsUpdateConstraints()
        statusOverlay.setNeedsDisplay()
        
        
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
    
    func configure(){
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2;
        nf.minimumFractionDigits = 2;
        nf.minimumIntegerDigits = 1
        
        self.titleLabel.text = bill!.name;
        self.costAllocationLabel.text = "$" + nf.string(from: NSNumber(value: bill!.subtotal))! + "/" + nf.string(from: NSNumber(value: bill!.total))!;
        
        
        var countPaid = 0
        var countTotal = 0
        bill!.payers.forEach({if $0.paid == true { countPaid += 1 }; countTotal += 1;})
        
        let img = #imageLiteral(resourceName: "Checkmark").withRenderingMode(.alwaysTemplate);
        
        if countPaid == countTotal { // not crop necessary
            statusOverlay.image = img.withRenderingMode(.alwaysTemplate)
            if bill!.date_paid == nil {
                if countPaid == 0 {
                    statusOverlay.isHidden = true;
                }
                else {
                    statusOverlay.isHidden = false;
                    statusOverlay.tintColor = UIColor(red: 255/255, green: 198/255, blue: 0/255, alpha: 1)
                }
            }
            else {
                statusOverlay.isHidden = false;
                statusOverlay.tintColor = UIColor(red: 37/255, green: 213/255, blue: 0, alpha: 1)
            }
            statusOverlayHeightConstraint = statusOverlayHeightConstraint.changeMultiplier(multiplier: 1)
        }
        else if countPaid == 0 {
            statusOverlay.isHidden = true;
        }
        else {
            
            let size: Double = Double(img.size.width*2);
            let cropmod: Double = Double(countTotal)
            let outOf: Double = Double(countTotal-countPaid);
            
            let crop = CGRect(x: 0, y: size * (outOf/cropmod) , width: size, height: size * ((cropmod-outOf)/cropmod))
            let img2 = img.cgImage?.cropping(to: crop);
            statusOverlay.image = UIImage(cgImage: img2!).withRenderingMode(.alwaysTemplate)
            statusOverlay.tintColor = UIColor(red: 255/255, green: 198/255, blue: 0/255, alpha: 1)
            statusOverlayHeightConstraint = statusOverlayHeightConstraint.changeMultiplier(multiplier: CGFloat(((cropmod-outOf)/cropmod)))
            statusOverlay.isHidden = false;
            
        }
 
        Util.getUser(user_id: String(bill!.owner_id), success: { user in
            self.ownerLabel.text = "Owner: " + user.name;
        }, error: {err in})
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
