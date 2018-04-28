//
//  ApiError.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/28/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation
import SwiftyJSON

class ApiError {
    
    var errors: [String] = [];
    
    init(json: JSON) {
        for (_, object) in json["errors"] {
            errors.append(object.stringValue)
        }
    }
    
    init(string: String) {
            errors.append(string)
    }
    
    func toString()-> String {
        var out = "";
        for err in errors {
            out += err + "\n";
        }
        return out;
    }
    
}
