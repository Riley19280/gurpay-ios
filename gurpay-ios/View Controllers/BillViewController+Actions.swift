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
                    //TODO: Delete Bill
                }
            )
        );
        alertController.addAction(
            UIAlertAction(
                title: "No",
                style: UIAlertActionStyle.destructive,
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
    
}
