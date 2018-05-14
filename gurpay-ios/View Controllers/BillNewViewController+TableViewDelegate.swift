//
//  BillNewViewController+TableViewDelegate.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 5/14/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation
import UIKit

extension BillNewViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payers.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillViewPayerCell", for: indexPath) as! BillViewPayerTableViewCell
        cell.nameLabel.text = payers[indexPath.row].name
        cell.statusLabel.text = "";
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25;
    }
    
    
}
