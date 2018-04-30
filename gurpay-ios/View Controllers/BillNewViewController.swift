//
//  BillNewViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class BillNewViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var billName: UITextField!
    @IBOutlet weak var billTotal: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var dueDate: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var errorLabel: UILabel!
    
    var firstResponder: UIView? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        billTotal.keyboardType = .decimalPad;
        datePicker.setValue(UIColor.white, forKey: "textColor")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createButtonClicked(_ sender: Any) {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MM/dd/YY"
        guard let da = dateFormatter.date(from: startDate.text!) else { displayError(text: "Date is in the incorrect format."); return;}
        guard let dd = dateFormatter.date(from: dueDate.text!) else { displayError(text: "Date is in the incorrect format."); return;}
        guard let to = Decimal(string: billTotal.text!) else { displayError(text: "Total should be a number."); return;}

        let bill = Bill(owner_id: 0, name: billName.text!, total: to, date_assigned: da, date_paid: nil, date_due: dd);
        
        ServiceBase.CreateBill(bill: bill,
            success: {
                self.navigationController?.popViewController(animated: true)
            },
            error: { err in
                self.displayError(text: err.toString());
            }
        )
        
    }
    
    func displayError(text: String){
        errorLabel.alpha = 1;
        errorLabel.text = text;
    }
    
    //MARK: Keyboard Stuff
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let next = textField.superview?.viewWithTag(textField.tag + 1)
        if( next != nil) {
            firstResponder = next;
            next!.becomeFirstResponder();
        }
        else {
            //done now
            firstResponder = nil;
            textField.resignFirstResponder();
        }
        return false;
    }
    
    @IBAction func dateValueChanged(_ sender: Any) {
        guard let fr = firstResponder as? UITextField else { return; }
        fr.text = Util.displayDate(date: datePicker.date);
    }
    
    @objc func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 2 || textField.tag == 3 {
            datePicker.isHidden = false;
            firstResponder = textField;
            textField.text = Util.displayDate(date: datePicker.date)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            return false;
        }
        datePicker.isHidden = true;
        
        return true;
    }
    

}
