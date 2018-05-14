//
//  BillViewPayersTableViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 5/14/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class BillViewPayersTableView: UITableView {
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        let height = contentSize.height
        return CGSize(width: contentSize.width, height: height)
    }

}
