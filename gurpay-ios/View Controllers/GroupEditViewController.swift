//
//  GroupEditViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class GroupEditViewController: UIViewController {

    @IBOutlet weak var groupCodeLabel: UILabel!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let group = Group.getFromDisk();
        groupCodeLabel.text = "Group Code: " + (group?.code)!;
        self.title = group?.name;
        
        editNameTextField.text = group?.name;
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayError(message: String) {
        errorLabel.alpha = 1;
        errorLabel.text = errorLabel.text! + "\n" + message;
    }
    
    @IBAction func changeClicked(_ sender: Any) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        let group = Group.getFromDisk();
        group?.name = editNameTextField.text!
    
        guard group != nil else { displayError(message: "An error occured while trying to update the group."); return; }

        ServiceBase.editGroup(
            group: group!,
            success: {
                _ = Group.writeToDisk(group: group!);
                self.title = group?.name;
            },
            error: {err in
                self.displayError(message: err.toString())
            }
        )
    }
    
    @IBAction func currentToArchiveClicked(_ sender: Any) {
        ServiceBase.GetBills(success: { bills in
      
        
            ServiceBase.archiveBills(bills: bills, success: {
                Util.displayBasicMessage(title: "Bill Archived", message: "Bills have been archived.")
            }, error: {err in
                self.displayError(message: err)
            })
        
            
        }, error: { err in
            self.displayError(message: err.toString())
        })
    }
    @IBAction func duplicateForNextMonthClicked(_ sender: Any) {
        ServiceBase.GetBills(success: { bills in
           
            ServiceBase.duplicateBills(bills: bills, success: {
                Util.displayBasicMessage(title: "Bill Duplicated", message: "Bills have been duplicated for next month.")
            }, error: { err in
                self.displayError(message: err)
            })
        
        }, error: { err in
            self.displayError(message: err.toString())
        })
    }
   
}
