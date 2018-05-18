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
        //print(UIDevice.current.identifierForVendor!.uuidString)
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
        
        Util.dateFormatter.dateFormat = "MM/dd/yy"
        Util.dateFormatter.timeZone = TimeZone.current;
        
      
        return Util.dateFormatter.string(for: date);

    }
    
    private static var userCache: [String:User] = [:];
    public static func getUser(user_id: String, success:@escaping (_: User) -> Void, error:@escaping (ApiError)->()){
        if userCache[user_id] != nil  {
            success(userCache[user_id]!);
        } else {
            ServiceBase.GetUser(user_id: String(user_id),
                success: { user in
                    userCache[user_id] = user;
                    success(user);
                },
                error: { err in
                    error(err);
                }
            )
        }
    }
}

public extension NSLayoutConstraint {
    
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
    
}
