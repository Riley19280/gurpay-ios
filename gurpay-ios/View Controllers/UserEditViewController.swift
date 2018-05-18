//
//  UserEditViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class UserEditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var editNameStackView: UIStackView!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var changeNameButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var leaveGroupButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var user: User?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Util.getUser(
            user_id: Util.getDeviceId(),
            success: { user in
                self.user = user;
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
    
    //TODO: Test changing name
    @IBAction func changeNameClicked(_ sender: Any) {
        ServiceBase.UpdateUser(
            name: editNameTextField.text!,
            success:{ user in
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
    
    //MARK Keyboard Stuff
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func editChanged(_ sender: UITextField) {
        if sender.text == user?.name {
            changeNameButton.isEnabled = false;
            changeNameButton.backgroundColor = UIColor.lightGray
        }
        else {
            changeNameButton.isEnabled = true;
            changeNameButton.backgroundColor = UIColor(red: 252/255, green: 106/255, blue: 53/255, alpha: 1)
        }
    }
    
}
