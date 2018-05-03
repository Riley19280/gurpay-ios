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
    @IBOutlet weak var errorLabel: UILabel!
    
    var firstResponder: UITextField? = nil;
    let dateFormatter = DateFormatter();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "MM/dd/yy"
        
        
        billTotal.keyboardType = .decimalPad;
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createButtonClicked(_ sender: Any) {
      
        let nf = NumberFormatter();
        
        guard let da = dateFormatter.date(from: startDate.text!) else { displayError(text: "Date is in the incorrect format."); return;}
        guard let dd = dateFormatter.date(from: dueDate.text!) else { displayError(text: "Date is in the incorrect format."); return;}
        guard let to = nf.number(from: billTotal.text!) else { displayError(text: "Total should be a number."); return;}
      
        let bill = Bill(owner_id: 0, name: billName.text!, total: Double(to), date_assigned: da, date_paid: nil, date_due: dd);
        
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
        let next = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField
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
    
    
    @IBAction func dateFieldEditBegin(_ sender: UITextField) {
        firstResponder = sender;
        
        let df = DateFormatter();
        df.dateFormat = "MM/dd/yy";
        
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        if let currentDate = df.date(from: sender.text!) {
            datePickerView.date = currentDate;
        }
        
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44 ));
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDone));
        toolbar.setItems([flexButton, doneButton], animated: true)
        
        sender.inputView = datePickerView
        sender.inputAccessoryView = toolbar;
        
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        guard  firstResponder != nil else { return; }
        firstResponder!.text = Util.displayDate(date: sender.date)
    }
    
    @objc func datePickerDone(){
        
        let next = firstResponder?.superview?.viewWithTag((firstResponder?.tag)! + 1) as? UITextField
        if( next != nil) {
            firstResponder = next;
            next!.becomeFirstResponder();
        }
        else {
            //done now
            firstResponder?.resignFirstResponder();
            firstResponder = nil;
            
            //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        
    }
    
   
    

}
