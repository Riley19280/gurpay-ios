//
//  ServiceConnection.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON
import SwiftKeychainWrapper

class ServiceBase {
    
    init() {
        ServiceBase.reloadHeaders()
    }
    
    //MARK: Properties
    static let baseURL = "https://dev.gurpay.com/api/"
    
    static var headers: HTTPHeaders = [
        "group-code": getGroupCode(),
        "device-id" : getDeviceId()
    ];
    
    //MARK: Helper functions
    private static func getGroupCode()-> String{
        let group = Group.getFromDisk();
        if group == nil {
            _ = genericHandleErrorCodes(code: 401);
            return "";
        }
        return group!.code;
    }
    
    private static func getDeviceId()->String{
        return UIDevice.current.identifierForVendor!.uuidString;
    }
    
    private static func reloadHeaders() {
        headers = [
            "group-code": getGroupCode(),
            "device-id" : getDeviceId()
        ]
    }
    
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
    
        nav.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK:Handle Errors
    //TODO: make this method effective
    static func genericHandleErrorCodes(code :Int?)->Bool {
        if(code != nil) {
            switch code! {
            case 401:
                //redirecting the user to the login screen
                
                if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                    let alertController = UIAlertController(
                        title: "Oops!",
                        message:"An error occured. We are trying to fix this!",
                        preferredStyle: UIAlertControllerStyle.alert
                    );
                    
                    alertController.addAction(
                        UIAlertAction(
                            title: "Dismiss",
                            style: UIAlertActionStyle.default,
                            handler: {_ in
                                nav.popToRootViewController(animated: true);
                                
                        }
                        )
                    );
                    
                    nav.present(alertController, animated: true, completion: nil)
                    return true;
                }
                
            default:
                return false;
            }
        }
        
        return false;
    }
    
    static func executeRequest(route: String, method:HTTPMethod, params: Parameters, headers: HTTPHeaders = headers,success:@escaping (JSON) -> Void, error:@escaping (Error)->()){
        
        Alamofire.request(baseURL + route, method: method, parameters: params,  encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value);
                    if json != JSON.null {
                      success(json);
                    }
                    else
                    {
                        success(JSON("[]"));
                    }
                    
                case .failure(let err):
                    if(!genericHandleErrorCodes(code: response.response?.statusCode)){
                        error(err);
                    }
                }
        }
        
    }
    
    static func example(success:@escaping () -> Void, error:@escaping (Error)->()){
        executeRequest(
            route: "exroute",
            method: .post,
            params: [
                "param1": "data1",
                "param2": "data2",
            ],
            success: { json in
                success();
            },
                error: { err in
                    error(err);
            }
        );
    }

    static func JoinGroup(group_code: String,group_name: String, user_name: String, success:@escaping () -> Void, error:@escaping (Error)->()){
        executeRequest(
            route: "group/join",
            method: .post,
            params: [
                "group_name": group_name,
                "user_name": user_name,
                "group_code": group_code,
            ],
            success: { json in
                let g = Group(name: json["name"].stringValue, code: json["code"].stringValue);
                guard let gs = g else { error("There was a problem joing the group." as! Error); return; }
                if gs.writeToDisk() {
                    _ = reloadHeaders();
                    success();
                }
                else {
                    error("There was a problem joing the group." as! Error)
                }
            },
                error: { err in
                    error(err);
            }
        );
    }
    
    
}

