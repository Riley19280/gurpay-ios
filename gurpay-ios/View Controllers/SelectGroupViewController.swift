//
//  SelectGroupViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class SelectGroupViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    
    //create view elements
    
    @IBOutlet weak var createStackView: UIStackView!
    
    @IBOutlet weak var createYourNameTextField: UITextField!
    @IBOutlet weak var createGroupNameTextField: UITextField!
    @IBOutlet weak var createCreateGroupButton: UIButton!
    
    @IBOutlet weak var createJoinGroupButton: UIButton!
    
    //join view elements
    @IBOutlet weak var joinStackView: UIStackView!
    
    @IBOutlet weak var joinYourNameTextField: UITextField!
    @IBOutlet weak var joinGroupCodeTextField: UITextField!
    @IBOutlet weak var joinJoinGroupButton: UIButton!
    
    @IBOutlet weak var joinCreateGroupButton: UIButton!
    
    //state for keeping track of which view is displayed
    enum State {
      case create
      case join
    }
    
    var state:State = State.join  {
        didSet {
            switch state {
            case .create:
                joinStackView.isHidden = true;
                createStackView.isHidden = false;
                
            case .join:
                 createStackView.isHidden = true;
                 joinStackView.isHidden = false;
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createJoinGroupButton.layer.cornerRadius = 10
        createJoinGroupButton.clipsToBounds = true
        //createJoinGroupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true

        
        joinCreateGroupButton.layer.cornerRadius = 10
        joinCreateGroupButton.clipsToBounds = true
        //joinCreateGroupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //create view stuff
    @IBAction func createCreateButtonClicked(_ sender: Any) {
        //called when the user creates a new group
        ServiceBase.JoinGroup(group_code: "", group_name: createGroupNameTextField.text!, user_name: createYourNameTextField.text!,
        success: {
                                
        },
        error: { err in
                                
        })
    }
    
    @IBAction func createJoinButtonClicked(_ sender: Any) {
        state = .join;
    }
    
    //join view stuff
    
    @IBAction func joinJoinButtonClicked(_ sender: Any) {
        //called when the user wants to join an existing group
        ServiceBase.JoinGroup(group_code: joinGroupCodeTextField.text!,group_name: "", user_name: joinYourNameTextField.text!,
            success: {
                let storyboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                let newViewController = storyboard.instantiateInitialViewController();
                
                let customViewControllersArray : NSArray = [newViewController as Any]
                self.navigationController?.viewControllers = customViewControllersArray as! [UIViewController]
                self.navigationController?.popToRootViewController(animated: true)
            },
            error: { err in
                ServiceBase.displayBasicMessage(title: "Error", message: "Unable to join the group at this time.")
            }
        )
    }
    
    @IBAction func joinCreateGroupButtonClicked(_ sender: Any) {
        state = .create;
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
