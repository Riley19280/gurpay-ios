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
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var totalField: UITextField!
    @IBOutlet weak var dateAssignedField: UITextField!
    @IBOutlet weak var datePaidField: UITextField!
    @IBOutlet weak var dateDueField: UITextField!
    @IBOutlet weak var setPaidButton: UIButton!
    
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var fieldCollection: [UITextField]!
    @IBOutlet var stackViewCollection: [UIStackView]!
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
                navigationItem.leftBarButtonItems?.forEach({$0.isEnabled = true})
                
            case .editing:
                editBarButtonItem.title = "Save"
                fieldCollection.forEach({ $0.isUserInteractionEnabled = true})
                fieldCollection.forEach({ $0.borderStyle = .roundedRect})
                navigationItem.leftBarButtonItems?.forEach({$0.isEnabled = false})
           
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;
        formatter.minimumIntegerDigits = 1;
        
        Util.getUser(
            id: Util.getDeviceId(),
            success: { user in
                if user.id == self.bill!.owner_id {
                    self.setPaidButton.isHidden = false;
                    
                } else {
                    self.editBarButtonItem.isEnabled = false;
                    self.editBarButtonItem.tintColor = UIColor.clear
                }
            },
            error: { err in
                //TODO: Hangle error
            }
        )
        
        // Do any additional setup after loading the view.
        if bill != nil {
            //configuring base bill properties
            nameField.text = bill!.name;
            totalField.text = formatter.string(from: bill!.total as! NSNumber)!;
            dateAssignedField.text = Util.displayDate(date: bill!.date_assigned)!
            datePaidField.text = Util.displayDate(date: bill!.date_paid)!
            dateDueField.text = Util.displayDate(date: bill!.date_due)!
            self.title = bill!.name;
            
            //configure payers stuff
            
            if bill!.payers.count > 0 {
                
               mainStackView.setCustomSpacing(32, after: stackViewCollection.last!)
                
                let payersSectionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 375, height: 25))
                payersSectionLabel.text = "Payers on this bill";
                payersSectionLabel.textAlignment = .center;
                payersSectionLabel.font = payersSectionLabel.font.withSize(30);
                payersSectionLabel.textColor = UIColor.white;
                mainStackView.addArrangedSubview(payersSectionLabel);
            }
            
            for p in bill!.payers {
                
                
                let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 375, height: 25))
                nameLabel.text = p.user.name;
                nameLabel.textColor = UIColor.white;
                
                
                let paidLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 375, height: 25))
                paidLabel.text = p.paid == true ? "Paid" : "Unpaid"
                paidLabel.textColor = UIColor.white;
                
                let stackView = UIStackView(arrangedSubviews: [nameLabel,paidLabel])
                stackView.frame = CGRect(x: 0, y: 0, width: 375, height: 25)
                stackView.axis = .horizontal;
                stackView.heightAnchor.constraint(equalToConstant: 25)
                
                mainStackView.addArrangedSubview(stackView);
               
               
            }
            
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
    
    
    //MARK: Text Entry Stuff
    
    @IBAction func textFieldPrimaryAction(_ sender: Any) {
        guard let sender = sender as? UITextField else { return; }
        sender.resignFirstResponder()
    }

    
    var currentEditingField: UITextField?;
    @IBAction func dateFieldEditBegin(_ sender: UITextField) {
        currentEditingField = sender;
        
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
        guard  currentEditingField != nil else { return; }
        currentEditingField!.text = Util.displayDate(date: sender.date)
    }
    
    @objc func datePickerDone(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
