//
//  BillViewController+Actions.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 5/8/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation
import UIKit

extension BillViewViewController {
    
    //delete duplicate addpayer notify edit add payer
    
    func actionDelete(_:UIAlertAction){
        let alertController = UIAlertController(
            title: "Delete bill?",
            message: "Are you sure you want to delete this bill?",
            preferredStyle: UIAlertControllerStyle.alert
        );

        alertController.addAction(
            UIAlertAction(
                title: "Yes",
                style: UIAlertActionStyle.destructive,
                handler: { _ in
                    ServiceBase.deleteBill(
                        bill: self.bill!,
                        success: {
                            self.navigationController?.popViewController(animated: true);
                        },
                        error: { err in
                            self.displayError(text: err.toString())
                        }
                    )
                }
            )
        );
        alertController.addAction(
            UIAlertAction(
                title: "No",
                style: UIAlertActionStyle.default,
                handler: { _ in
                    
                }
            )
        );
        
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    func actionDuplicate(_:UIAlertAction) {
        
    }
    
    func actionAddPayer(_:UIAlertAction){
        performSegue(withIdentifier: "SelectPayers", sender: self);
    }
    
    func actionNotifyUnpaid(_:UIAlertAction){
        
    }
    
    func actionEdit(_:UIAlertAction){
        state = .editing;
    }
    
    func addPayers(users: [User]){
        ServiceBase.addPayers(
            bill: bill!,
            users: users,
            success: {
                    
            },
            error: {err in
                self.displayError(text: err.toString())
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let dest = nav.viewControllers.first as? SelectPayersTableViewController {
                var filter: [User] = [];
                for payer in bill!.payers {
                    filter.append(payer.user)
                }
                dest.filterUsers = filter;
                dest.myRootViewController = self;
            }
        }
    }
    
}
