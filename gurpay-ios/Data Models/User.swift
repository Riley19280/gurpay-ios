//
//  User.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation

class User: Codable {
    
    var id: Int;
    var device_id: String = "";
    var name: String;
    var group_code: String;
    
    
    init(id: Int, name: String, group_code: String) {
        self.id = id;
        self.name = name;
        self.group_code = group_code;
    }
    
}
