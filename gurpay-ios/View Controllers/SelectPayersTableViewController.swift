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
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelection = true;
        
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
    
    

    func loadData(){
        
        ServiceBase.getGroupMembers(
            success: { users in
                if users.count == 0 { self.errorLabel.isHidden = false; return; }
                
                self.users = users;
                self.tableView.reloadData();
                
            }, error: { _ in
                self.errorLabel.text = "There was an error getting the groups' members."
                self.errorLabel.isHidden = false;
            }
        )
        
    }
    @IBAction func doneClicked(_ sender: Any) {
        
        guard let rvc = myRootViewController as? BillViewViewController else { return; }
        
        var selectedUsers: [User] = [];
        
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return; }
        
        for path in selectedRows {
            selectedUsers.append(users[path.row]);
        }
        
        rvc.setPayers(users);
        navigationController?.popViewController(animated: true);
    }
    
}
