//
//  SelectGroupViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class SelectGroupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    
    //create view elements
    
    @IBOutlet weak var createSuperview: UIView!
    @IBOutlet weak var createStackView: UIStackView!
    
    @IBOutlet weak var createYourNameTextField: UITextField!
    @IBOutlet weak var createGroupNameTextField: UITextField!
    @IBOutlet weak var createCreateGroupButton: UIButton!
    
    @IBOutlet weak var createJoinGroupButton: UIButton!
    
    //join view elements
    @IBOutlet weak var joinSuperview: UIView!
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
                joinSuperview.isHidden = true;
                createSuperview.isHidden = false;
                
            case .join:
                 createSuperview.isHidden = true;
                 joinSuperview.isHidden = false;
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //createJoinGroupButton.layer.cornerRadius = 10
        //createJoinGroupButton.clipsToBounds = true
        //createJoinGroupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true

        
        //joinCreateGroupButton.layer.cornerRadius = 10
        //joinCreateGroupButton.clipsToBounds = true
        //joinCreateGroupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        joinGroupCodeTextField.keyboardType = .numberPad
        
    }
    
    override func viewDidLayoutSubviews() {
        let shadowPath = UIBezierPath(rect: createSuperview.bounds)
        createSuperview.layer.cornerRadius = 10
        createSuperview.layer.masksToBounds = false
        createSuperview.layer.shadowRadius = 4
        createSuperview.layer.shadowColor = UIColor.black.cgColor
        createSuperview.layer.shadowOffset = CGSize(width: 1, height: 1)
        createSuperview.layer.shadowOpacity = 0.3
        createSuperview.layer.shadowPath = shadowPath.cgPath
        
        let shadowPath1 = UIBezierPath(rect: joinSuperview.bounds)
        joinSuperview.layer.cornerRadius = 10
        joinSuperview.layer.masksToBounds = false
        joinSuperview.layer.shadowRadius = 4
        joinSuperview.layer.shadowColor = UIColor.black.cgColor
        joinSuperview.layer.shadowOffset = CGSize(width: 1, height: 1)
        joinSuperview.layer.shadowOpacity = 0.3
        joinSuperview.layer.shadowPath = shadowPath1.cgPath
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Create view stuff
    
    @IBAction func createCreateButtonClicked(_ sender: Any) {
        //called when the user creates a new group
        ServiceBase.JoinGroup(group_code: "", group_name: createGroupNameTextField.text!, user_name: createYourNameTextField.text!,
        success: {
            let newViewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateInitialViewController()!
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setRootViewController(controller: newViewController)
        },
        error: { err in
             self.displayErrorMessage(msg: err.toString())
        })
    }
    
    @IBAction func createJoinButtonClicked(_ sender: Any) {
        state = .join;
    }
    
    //MARK: Join view stuff
    
    @IBAction func joinJoinButtonClicked(_ sender: Any) {
        //called when the user wants to join an existing group
        ServiceBase.JoinGroup(group_code: joinGroupCodeTextField.text!,group_name: "", user_name: joinYourNameTextField.text!,
            success: {
                let newViewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateInitialViewController()!
               
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.setRootViewController(controller: newViewController)
                
                //self.performSegue(withIdentifier: "toDashboard", sender: self)
                
                //self.navigationController!.pushViewController(newViewController!, animated: true)
                
              /*  let customViewControllersArray : NSArray = [newViewController as Any]
                self.navigationController?.viewControllers = customViewControllersArray as! [UIViewController]
                self.navigationController?.popToRootViewController(animated: true)*/
            },
            error: { err in
                //ServiceBase.displayBasicMessage(title: "Error", message: "Unable to join the group at this time.")
                self.displayErrorMessage(msg: err.toString())
            }
        )
    }
    
    @IBAction func joinCreateGroupButtonClicked(_ sender: Any) {
        state = .create;
    }
    
    
    //MARK: Helper functions
    
    private func displayErrorMessage(msg: String){
        if(msg != ""){
            errorLabel.text = msg;
            errorLabel.isHidden = false
        }
        else {
            errorLabel.isHidden = true;
        }
        
    }
    
    //MARK: keyboard Stuff
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder?
        
        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        
        return false
    }
    @objc func dismissKeyboard(tap: UITapGestureRecognizer){
        let point = tap.location(in: self.view)
        
       
        
        view.endEditing(true)
    }

}
