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
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var totalField: UITextField!
    @IBOutlet weak var dateAssignedField: UITextField!
    @IBOutlet weak var datePaidField: UITextField!
    @IBOutlet weak var dateDueField: UITextField!
    @IBOutlet weak var setPaidButton: UIButton!
    
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var fieldCollection: [UITextField]!
    enum State {
        case normal
        case editing
    }
    
    var state:State = State.normal  {
        didSet {
            switch state {
            case .normal:
                editBarButtonItem.title = "Edit"
                fieldCollection.forEach({ $0.isUserInteractionEnabled = false})
                fieldCollection.forEach({ $0.borderStyle = .none})
                updateBill();
            case .editing:
                editBarButtonItem.title = "Done"
                fieldCollection.forEach({ $0.isUserInteractionEnabled = true})
                fieldCollection.forEach({ $0.borderStyle = .roundedRect})
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

          let formatter = NumberFormatter()
        
        Util.getUser(
            id: Util.getDeviceId(),
            success: { user in
                if user.id == self.bill!.owner_id {
                    self.setPaidButton.isHidden = false;
                }
            },
            error: { err in
                //TODO: Hangle error
            }
        )
        
        // Do any additional setup after loading the view.
        if bill != nil {
            nameField.text = bill!.name;
            totalField.text = formatter.string(from: bill!.total as! NSNumber)!;
            dateAssignedField.text = Util.displayDate(date: bill!.date_assigned)!
            datePaidField.text = Util.displayDate(date: bill!.date_paid)!
            dateDueField.text = Util.displayDate(date: bill!.date_due)!
            
            self.title = bill!.name;
        }
        
        
        
    }
    
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      }
      
    @IBAction func editClicked(_ sender: Any) {
        if state == .normal
        {
            state = .editing;
        }
        else
        {
            state = .normal
        }
    }
    
    @IBAction func setPaidClicked(_ sender: Any) {
        let date = Date();
        datePaidField.text = Util.displayDate(date: date)
        bill?.date_paid = date;
        updateBill()
    }
    
    func updateBill() {
        ServiceBase.updateBill(
            bill: bill!,
            success: {
                //TODO: handle update bill
            },
            error: { err in
                Util.displayBasicMessage(title: "Error", message: err.toString())
            }
        )
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
