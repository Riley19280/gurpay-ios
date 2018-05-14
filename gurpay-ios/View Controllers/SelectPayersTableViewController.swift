//
//  SelectPayersTableViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 5/10/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class SelectPayersTableViewController: UITableViewController {

    var myRootViewController: UIViewController?;
    var users: [User] = [];
    var filterUsers: [User] = [];
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navBar = UINavigationBar()
        navBar.setItems([UINavigationItem(title: "Test")], animated: true)
        
        self.view.addSubview(navBar)
        
        tableView.allowsMultipleSelection = true;
        
        loadData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayerCell", for: indexPath) as! SelectPayersTableViewCell
        
        cell.user = users[indexPath.row];
      
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52;
    }
    

    func loadData(){
        ServiceBase.GetUser(
            user_id: Util.getDeviceId(),
            success: { user in
                self.filterUsers.append(user);
                ServiceBase.getGroupMembers(
                    success: { users in
                       
                        
                        for user in users {
                            if self.filterUsers.contains(where: {return $0.id == user.id})  {
                                continue
                            }
                            self.users.append(user);
                        }
                        
                        if self.users.count == 0 { self.errorLabel.isHidden = false; return; }
                        self.tableView.reloadData();
                        
                    },
                    error: { _ in
                        self.errorLabel.text = "There was an error getting the groups' members."
                        self.errorLabel.isHidden = false;
                    }
                )
            },
            error: { err in
                self.errorLabel.text = "There was an error getting the groups' members."
                self.errorLabel.isHidden = false;
            }
        )
        
       
        
    }
    @IBAction func doneClicked(_ sender: Any) {

        var selectedUsers: [User] = [];
        guard let selectedRows = tableView.indexPathsForSelectedRows else { self.dismiss(animated: true, completion: nil); return; }
        for path in selectedRows {
            selectedUsers.append(users[path.row]);
        }
        
        if let billVC = myRootViewController as? BillViewViewController {
            billVC.addPayers(users: selectedUsers);
        }
        if let billVC = myRootViewController as? BillNewViewController {
            billVC.addPayers(users: selectedUsers);
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
