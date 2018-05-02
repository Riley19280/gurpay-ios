//
//  Util.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/28/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON
import SwiftKeychainWrapper

class Util {
    
    private static let dateFormatter = DateFormatter();

    public static func displayBasicMessage(title: String,message: String, button: String = "Dismiss") {
        if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            );
            
            alertController.addAction(
                UIAlertAction(
                    title: button,
                    style: UIAlertActionStyle.default,
                    handler: {_ in
                }
                )
            );
            
            nav.visibleViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    public static func getDeviceId()->String{
        print(UIDevice.current.identifierForVendor!.uuidString)
        return UIDevice.current.identifierForVendor!.uuidString;
    }
    
    public static func formatDate(string: String)-> Date? {
        Util.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        Util.dateFormatter.timeZone = TimeZone.current;

        if string.isEmpty {
            return nil;
        }
        else {
            return Util.dateFormatter.date(from: string)!;
        }
        
    }
    
    public static func displayDate(date: Date?)-> String? {
        if date == nil { return "" }
        
        Util.dateFormatter.dateFormat = "MM/dd/YY"
        Util.dateFormatter.timeZone = TimeZone.current;
        
      
        return Util.dateFormatter.string(for: date);

    }
    
    private static var userCache: [User] = [];
    public static func getUser(id: String, success:@escaping (_: User) -> Void, error:@escaping (ApiError)->()){
        if userCache.contains(where: { return String($0.id) == id || $0.device_id == id })  {
            success(userCache.first(where: { String($0.id) == id || $0.device_id == id })!);
        } else {
            ServiceBase.GetUser(user_id: String(id),
                success: { user in
                    success(user);
                },
                error: { err in
                    error(err);
                }
            )
        }
    }
}
