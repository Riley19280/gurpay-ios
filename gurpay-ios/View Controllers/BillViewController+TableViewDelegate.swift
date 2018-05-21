//
//  BillViewController+TableViewDelegate.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 5/14/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation
import UIKit

extension BillViewViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bill!.payers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillViewPayerCell", for: indexPath) as! BillViewPayerTableViewCell
        cell.payer = self.bill!.payers[indexPath.row];
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 30;
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let removeAction = UITableViewRowAction(style: .default, title: "Remove", handler: {_,_ in
            ServiceBase.deletePayers(
                bill: self.bill!,
                users: [self.bill!.payers[indexPath.row].user],
                success: {
                    self.bill!.payers.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.invalidateIntrinsicContentSize()
                },
                error: {err in
                    //TODO: Handle Error
                }
            )
        })
          
        removeAction.backgroundColor = UIColor(red: 252/255, green: 106/255, blue: 53/255, alpha: 1)
        return [removeAction]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if state == .editing {
            return true;
        }
        return false;
     }

    
}
