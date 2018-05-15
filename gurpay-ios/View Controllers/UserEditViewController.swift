//
//  UserEditViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class UserEditViewController: UIViewController {

    @IBOutlet weak var editNameStackView: UIStackView!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var changeNameButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var leaveGroupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Util.getUser(
            user_id: Util.getDeviceId(),
            success: { user in
                self.editNameTextField.text = user.name;
            },
            error: { err in
                self.editNameStackView.isHidden = true;
                self.errorLabel.text = "An error occured.";
                self.errorLabel.isHidden = false;
                self.leaveGroupButton.isHidden = true;
            }
        )
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TODO: Test changing name
    @IBAction func changeNameClicked(_ sender: Any) {
        ServiceBase.UpdateUser(
            name: editNameTextField.text!,
            success:{ user in
                self.title = user.name
                self.editNameTextField.text = user.name;
            },
            error: { err in
                self.errorLabel.text = err.toString();
                self.errorLabel.isHidden = false;
            }
        )
    }
    
    //TODO: Test leaving group
    @IBAction func leaveGroupCicked(_ sender: Any) {
        
        let alertController = UIAlertController(
            title: "Leave group?",
            message:"If you leave the group, all of the bills you own will be deleted. Are you sure that you want to leave the group?",
            preferredStyle: UIAlertControllerStyle.alert
        );
        
        alertController.addAction(
            UIAlertAction(
                title: "Yes",
                style: UIAlertActionStyle.default,
                handler: {_ in
                    ServiceBase.LeaveGroup(
                        success: {
                            if Group.deleteData() {
                                let vc = UIStoryboard.init(name: "SelectGroup", bundle: nil).instantiateInitialViewController()!
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.setRootViewController(controller: vc)
                            }
                        },
                        error: { err in
                            self.errorLabel.text = err.toString();
                            self.errorLabel.isHidden = false;
                        }
                    )
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "No",
                style: UIAlertActionStyle.default,
                handler: nil
            )
        )
        
        self.present(alertController, animated: true, completion: nil)
        
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
