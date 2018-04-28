//
//  Bill.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation

class Bill: Codable {
    
    var owner_id: Int;
    var name: String;
    var total: Decimal;
    var date_assigned: Date;
    var date_paid: Date?;
    var date_due: Date;
    
    init(owner_id: Int, name: String, total: Decimal, date_assigned: Date, date_paid: Date, date_due: Date) {
        self.owner_id = owner_id;
        self.name = name;
        self.total = total;
        self.date_assigned = date_assigned;
        self.date_paid = date_paid;
        self.date_due = date_due;
    }
    
    init(owner_id: Int, name: String, total: Decimal, date_assigned: String, date_paid: String, date_due: String) {
        self.owner_id = owner_id;
        self.name = name;
        self.total = total;
        self.date_assigned = Util.formatDate(string: date_assigned)!;
        self.date_paid = Util.formatDate(string: date_paid);
        self.date_due = Util.formatDate(string: date_due)!;
    }
    
}
