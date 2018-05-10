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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let group = Group.getFromDisk();
        groupCodeLabel.text = "Group Code:" + (group?.code)!;
        self.title = group?.name;
        
        editNameTextField.text = group?.name;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayError(message: String) {
        errorLabel.alpha = 1;
        errorLabel.text = message;
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
    }
    @IBAction func duplicateForNextMonthClicked(_ sender: Any) {
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
