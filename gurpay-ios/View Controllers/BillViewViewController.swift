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
    
    @IBOutlet weak var actionsBarButtonItem: UIBarButtonItem!
    
    
    @IBOutlet var fieldCollection: [UITextField]!
    @IBOutlet var stackViewCollection: [UIStackView]!
    
    enum State {
        case normal
        case editing
    }
    var allowEdit: Bool = false;
    
    var state:State = State.normal  {
        didSet {
            switch state {
            case .normal:
                actionsBarButtonItem.title = "Actions"
                fieldCollection.forEach({ $0.isUserInteractionEnabled = false})
                fieldCollection.forEach({ $0.borderStyle = .none})
                navigationItem.leftBarButtonItems?.forEach({$0.isEnabled = true})
                
            case .editing:
                actionsBarButtonItem.title = "Save"
                fieldCollection.forEach({ $0.isUserInteractionEnabled = true})
                fieldCollection.forEach({ $0.borderStyle = .roundedRect})
                navigationItem.leftBarButtonItems?.forEach({$0.isEnabled = false})
           
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        Util.getUser(
            id: Util.getDeviceId(),
            success: { user in
                if user.id == self.bill!.owner_id {
                    self.setPaidButton.isHidden = false;
                    self.allowEdit = true;
                }
            },
            error: { err in
                //TODO: Handle error
            }
        )
        
        initializeUI();
        
        if(bill!.is_archive) {
            self.allowEdit = false;
            self.setPaidButton.isHidden = false;
            navigationItem.rightBarButtonItems = nil;
            navigationItem.rightBarButtonItem = nil;
        }
    }
    
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      }
    
    //MARK: Functions
    
    @IBAction func editClicked(_ sender: Any) {
       
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
    
    @IBAction func actionsItemClicked(_ sender: Any) {

        if state == .editing
        {
            state = .normal;
            return;
        }
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet
        );
        
        if allowEdit {
            alertController.addAction(
                UIAlertAction(
                    title: "Delete",
                    style: UIAlertActionStyle.destructive,
                    handler: actionDelete
                )
            );
        
            alertController.addAction(
                UIAlertAction(
                    title: "Duplicate bill for next month",
                    style: UIAlertActionStyle.default,
                    handler: actionDuplicate
                )
            );
            alertController.addAction(
                UIAlertAction(
                    title: "Add Payers to bill",
                    style: UIAlertActionStyle.default,
                    handler: actionAddPayer
                )
            );
            alertController.addAction(
                UIAlertAction(
                    title: "Notify those who haven't paid",
                    style: UIAlertActionStyle.default,
                    handler: actionNotifyUnpaid
                )
            );
            alertController.addAction(
                UIAlertAction(
                    title: "Edit bill",
                    style: UIAlertActionStyle.default,
                    handler: actionEdit
                )
            );
        }
        else {
            alertController.addAction(
                UIAlertAction(
                    title: "Mark as paid",
                    style: UIAlertActionStyle.default,
                    handler: {_ in }
                )
            );
        }
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.cancel,
                handler: {_ in }
            )
        );
        
        navigationController?.present(alertController, animated: true, completion: nil)
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
    
    func initializeUI(){
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;
        formatter.minimumIntegerDigits = 1;
        
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
    
}
