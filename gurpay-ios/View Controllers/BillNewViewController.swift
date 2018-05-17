//
//  BillNewViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class BillNewViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var tableView: BillViewPayersTableView!
    
    @IBOutlet weak var billName: UITextField!
    @IBOutlet weak var billTotal: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var dueDate: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var firstResponder: UITextField? = nil;
    let dateFormatter = DateFormatter();
    
    var payers: [User] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "MM/dd/yy"
        
        billTotal.keyboardType = .decimalPad;

        stackView.setCustomSpacing(8, after: dueDate)
        
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.register(UINib(nibName: "BillViewPayerTableViewCell", bundle: nil), forCellReuseIdentifier: "BillViewPayerCell")
        
    }
    
    override func viewDidLayoutSubviews() {
        let shadowPath = UIBezierPath(rect: bgView.bounds)
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = false
        bgView.layer.shadowRadius = 4
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 1, height: 1)
        bgView.layer.shadowOpacity = 0.3
        bgView.layer.shadowPath = shadowPath.cgPath
        
        tableView.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createButtonClicked(_ sender: Any) {
      
        let nf = NumberFormatter();
        
        guard let da = dateFormatter.date(from: startDate.text!) else { displayError(text: "Start date is in the incorrect format."); return;}
        guard let dd = dateFormatter.date(from: dueDate.text!) else { displayError(text: "Due date is in the incorrect format."); return;}
        guard let to = nf.number(from: billTotal.text!) else { displayError(text: "Total should be a number."); return;}
      
        let bill = Bill(id: 0, owner_id: 0, name: billName.text!, total: Double(truncating: to), date_assigned: da, date_paid: nil, date_due: dd,is_archive: false);
        
        ServiceBase.CreateBill(bill: bill,
            success: { bill in
                
                if self.payers.count == 0 {
                    self.navigationController?.popViewController(animated: true)
                    return;
                }
                
                ServiceBase.addPayers(
                    bill: bill,
                    users: self.payers,
                    success: { user in
                        self.navigationController?.popViewController(animated: true)
                    },
                    error: {err in
                        self.displayError(text: err.toString())
                        self.navigationController?.popViewController(animated: true)
                    }
                )
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
    
    

    func addPayers(users: [User]){
        payers.append(contentsOf: users)
        tableView.reloadData()
        tableView.invalidateIntrinsicContentSize()
    }
    //MARK: Payers stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let dest = nav.viewControllers.first as? SelectPayersTableViewController {
                dest.filterUsers = payers;
                dest.myRootViewController = self;
            }
        }
    }
    
    //MARK: Keyboard Stuff
    @IBAction func fieldEditBegin(_ sender: UITextField) {
         firstResponder = sender;
        
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44 ));
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(keyboardDone));
        
        let next = sender.superview?.viewWithTag((firstResponder?.tag)! + 1) as? UITextField
        if( next != nil) {
            doneButton.title = "Next";
        }

        
        toolbar.setItems([flexButton, doneButton], animated: true)
        
        sender.inputAccessoryView = toolbar
        
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
        sender.text = df.string(from: datePickerView.date)
        
        
        
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44 ));
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(keyboardDone));
        
        let next = firstResponder?.superview?.viewWithTag((firstResponder?.tag)! + 1) as? UITextField
        if( next != nil) {
            doneButton.title = "Next";
        }
        
        
        toolbar.setItems([flexButton, doneButton], animated: true)
        
        sender.inputView = datePickerView
        sender.inputAccessoryView = toolbar;
        
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        guard  firstResponder != nil else { return; }
        firstResponder!.text = Util.displayDate(date: sender.date)
    }
    
    @objc func keyboardDone(){
        
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
