//
//  BillViewViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class BillViewViewController: UIViewController {

    var bill: Bill? = nil;
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var dateAssignedLabel: UILabel!
    @IBOutlet weak var datePaidLabel: UILabel!
    @IBOutlet weak var dateDueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = bill?.name;
        totalLabel.text = String(describing: bill?.total);
        dateAssignedLabel.text = Util.displayDate(date: bill?.date_assigned)
        datePaidLabel.text = Util.displayDate(date: (bill?.date_paid)!)
        dateDueLabel.text = Util.displayDate(date: bill?.date_due)
        
        self.title = bill?.name;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is Bill {
            self.bill = (sender as! Bill);
        }
        else {
            fatalError("Bil has incorrect sender.")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
