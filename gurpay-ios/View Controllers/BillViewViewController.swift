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
    @IBOutlet weak var addPayerButton: UIButton!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var payPerPersonLabel: UILabel!
    
    @IBOutlet weak var actionsBarButtonItem: UIBarButtonItem!
    
    
    @IBOutlet var fieldCollection: [UITextField]!
    @IBOutlet var stackViewCollection: [UIStackView]!
    
    @IBOutlet weak var payersTableView: UITableView!
    
    let dateFormatter = DateFormatter();
    
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
                addPayerButton.isHidden = true;
                navigationItem.leftBarButtonItems?.forEach({$0.isEnabled = true})
                self.setEditing(false, animated: true)
            case .editing:
                actionsBarButtonItem.title = "Save"
                fieldCollection.forEach({ $0.isUserInteractionEnabled = true})
                fieldCollection.forEach({ $0.borderStyle = .roundedRect})
                addPayerButton.isHidden = false;
                navigationItem.leftBarButtonItems?.forEach({$0.isEnabled = false})
                self.setEditing(true, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        Util.getUser(
            user_id: Util.getDeviceId(),
            success: { user in
                if user.id == self.bill!.owner_id {
                    if self.bill!.date_paid != nil || self.bill!.is_archive {
                        self.setPaidButton.isHidden = true;
                    }
                    else {
                        self.setPaidButton.isHidden = false;
                    }
                    
                    self.allowEdit = true;
                }
                self.buildActionHandler(user: user);
                
            },
            error: { err in
                //TODO: Handle error
            }
        )

        if bill!.is_archive {
            self.allowEdit = false;
            self.setPaidButton.isHidden = true;
            navigationItem.rightBarButtonItems = nil;
            navigationItem.rightBarButtonItem = nil;
            
        }
        
        payersTableView.register(UINib(nibName: "BillViewPayerTableViewCell", bundle: nil), forCellReuseIdentifier: "BillViewPayerCell")
        
        payersTableView.delegate = self;
        payersTableView.dataSource = self;
        payersTableView.reloadData();
        
        initializeUI()
        
       
    }
    
    override func viewDidLayoutSubviews() {
        self.payersTableView.invalidateIntrinsicContentSize()
    }
    
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      }
    
    //MARK: Functions    
    @IBAction func setPaidClicked(_ sender: UIButton) {
        let date = Date();
        datePaidField.text = Util.displayDate(date: date)
        sender.isHidden = true;
        bill?.date_paid = date;
        updateBill()
    }
    
    func updateBill() {
        let nf = NumberFormatter();
        nf.maximumFractionDigits = 2;
        nf.minimumFractionDigits = 2;
        nf.minimumIntegerDigits = 1
        
        dateFormatter.dateFormat = "MM/dd/yy"
        guard let da = dateFormatter.date(from: dateAssignedField.text!) else { displayError(text: "Date assigned is in the incorrect format."); return;}
        guard let dd = dateFormatter.date(from: dateDueField.text!) else { displayError(text: "Due date is in the incorrect format."); return;}
        guard let dp = dateFormatter.date(from: dateDueField.text!) else { displayError(text: "Date paid is in the incorrect format."); return;}
        guard let to = nf.number(from: totalField.text!) else { displayError(text: "Total should be a number."); return;}
        
        bill?.name = nameField.text!;
        bill?.total = Double(truncating: to);
        bill?.date_assigned = da;
        bill?.date_paid = dp;
        bill?.date_due = dd;
        bill?.split_cost = Double(truncating: nf.number(from: String(bill!.total/Double((bill!.payers.count+1))))!)
        
        ServiceBase.updateBill(
            bill: bill!,
            success: {
                self.state = .normal;
                self.initializeUI()
            },
            error: { err in
                Util.displayBasicMessage(title: "Error", message: err.toString())
            }
        )
    }
    
    //MARK: Error Handler
    func displayError(text: String) {
        
        let alertController = UIAlertController(
            title: "Error",
            message: text,
            preferredStyle: UIAlertControllerStyle.alert
        );
        alertController.addAction(
            UIAlertAction(
                title: "Dismiss",
                style: UIAlertActionStyle.default,
                handler: {_ in }
            )
        );
        
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Action Handler
    let actionAlertController = UIAlertController(
        title: nil,
        message: nil,
        preferredStyle: UIAlertControllerStyle.actionSheet
    );
    
    func buildActionHandler(user: User){
        
        if allowEdit {
            actionAlertController.addAction(
                UIAlertAction(
                    title: "Delete",
                    style: UIAlertActionStyle.destructive,
                    handler: actionDelete
                )
            );
            
            actionAlertController.addAction(
                UIAlertAction(
                    title: "Duplicate bill for next month",
                    style: UIAlertActionStyle.default,
                    handler: actionDuplicate
                )
            );
            actionAlertController.addAction(
                UIAlertAction(
                    title: "Notify those who haven't paid",
                    style: UIAlertActionStyle.default,
                    handler: actionNotifyUnpaid
                )
            );
            if bill?.date_paid != nil {
                actionAlertController.addAction(
                    UIAlertAction(
                        title: "Archive Bill",
                        style: UIAlertActionStyle.default,
                        handler: actionArchive
                    )
                );
            }
            actionAlertController.addAction(
                UIAlertAction(
                    title: "Edit bill",
                    style: UIAlertActionStyle.default,
                    handler: actionEdit
                )
            );
        }
        else {
 
            if self.bill!.payers.contains(where: {return ($0.user.id == user.id && $0.paid == false)}) {
                self.actionAlertController.addAction(
                    UIAlertAction(
                        title: "Mark as paid",
                        style: UIAlertActionStyle.default,
                        handler: self.actionMarkPaid
                    )
                );
            }
            else {
                self.navigationItem.rightBarButtonItems = nil;
                self.navigationItem.rightBarButtonItem = nil;
            }
       
            
        }
        actionAlertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.cancel,
                handler: {_ in }
            )
        );
    }

    @IBAction func actionsItemClicked(_ sender: Any) {

        if state == .editing
        {
            updateBill();
            return;
        }
        
        navigationController?.present(actionAlertController, animated: true, completion: nil)
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
            payPerPersonLabel.text = "Amount per person: $" + String(bill!.split_cost)
            
            
            Util.getUser(user_id: String(bill!.owner_id), success: {user in
                self.ownerLabel.text = "Owner: " + user.name;
            }, error: {err in
                self.ownerLabel.text = "Owner: Unknown";
            })
        }
    }
}
