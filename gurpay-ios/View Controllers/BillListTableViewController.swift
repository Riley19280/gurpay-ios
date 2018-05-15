//
//  BillListTableViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class BillListTableViewController: UITableViewController {

    var bills: [Bill] = [];
    
    var isArchive = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "BillTableViewCell", bundle: nil), forCellReuseIdentifier: "BillCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        if(isArchive) {
            navigationItem.rightBarButtonItems = nil;
            navigationItem.rightBarButtonItem = nil;
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        loadData();
    }
    
    @objc func loadData(){
        ServiceBase.GetBills(
            archived: isArchive,
            success: { bills in
                self.bills = bills;
                self.tableView.reloadData();
                self.refreshControl?.endRefreshing();
            },
            error: { err in
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                
                label.textAlignment = .center
                label.text = "There was an error loading your groups bills."
                self.view.addSubview(label)
                
                label.translatesAutoresizingMaskIntoConstraints = false
                let horizontalConstraint = label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
                let verticalConstraint = label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
                let widthConstraint = label.widthAnchor.constraint(equalTo: self.view.widthAnchor)
                let heightConstraint = label.heightAnchor.constraint(equalToConstant: 20)
                NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
                self.refreshControl?.endRefreshing();
            }
        )
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
        return bills.count;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath) as! BillTableViewCell
        
        cell.bill = bills[indexPath.row];

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToBillView", sender: self);
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BillViewViewController {
            guard tableView.indexPathForSelectedRow != nil else { return; }
            (segue.destination as! BillViewViewController).bill = bills[tableView.indexPathForSelectedRow!.row];
        }
        else {
//           / fatalError("Bil has incorrect segue.")
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
