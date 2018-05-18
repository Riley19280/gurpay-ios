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
        ServiceBase.duplicateBills(bills: [bill!], success: {
            Util.displayBasicMessage(title: "Bill Duplicated", message: "Bill successfully duplicated.")
        }, error: { err in
            self.displayError(text: err)
        })
        
    }
    
    @IBAction func actionAddPayer(_:UIAlertAction) {
        performSegue(withIdentifier: "SelectPayers", sender: self);
    }
    
    func actionNotifyUnpaid(_:UIAlertAction) {
        ServiceBase.notifyUnpaidPayers(
            bill: bill!,
            success: {
                Util.displayBasicMessage(title: "Payers notified", message: "Payers who have not yet paid have been notified.")
            },
            error: {err in
                
            })
    }
    
    func actionEdit(_:UIAlertAction) {
        state = .editing;
    }
    
    func actionMarkPaid(_:UIAlertAction) {
        ServiceBase.markPayerPaid(
            bill: bill!,
            success: {
                Util.getUser(
                    user_id: Util.getDeviceId(),
                    success: {user in
                        (self.bill!.payers.first(where: {return $0.user.id == user.id}))!.paid = true;
                        self.payersTableView.reloadData()
                    },
                    error: {_ in
                        //TODO: Handle Error
                    }
                )
            },
            error: {err in
                //TODO: Handle Error
            }
        )
    }
    
    func actionArchive(_:UIAlertAction){
        ServiceBase.archiveBills(bills: [bill!], success: {
            Util.displayBasicMessage(title: "Bill archived", message: "Bill successfully archived.")
        }, error: { err in
            self.displayError(text: err)
        })
    }
    
    //MARK: Helper Functions
    
    func addPayers(users: [User]){
        ServiceBase.addPayers(
            bill: bill!,
            users: users,
            success: { user in
                self.payersTableView.beginUpdates()
                self.bill!.payers.append(UserPaid(user: user, paid: false))
                self.payersTableView.insertRows(at: [IndexPath(item: self.bill!.payers.count-1, section: 0)], with: .fade)
                self.payersTableView.endUpdates()
                self.payersTableView.invalidateIntrinsicContentSize()
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
