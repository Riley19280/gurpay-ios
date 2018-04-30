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
    static let baseURL = "https://rileystech.com/gurpay/api/"
    
    static var headers: HTTPHeaders = [
        "group-code": getGroupCode(),
        "device-id" : Util.getDeviceId()
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

    private static func reloadHeaders() {
        headers = [
            "group-code": getGroupCode(),
            "device-id" : Util.getDeviceId()
        ]
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
                    
                    nav.visibleViewController?.present(alertController, animated: true, completion: nil)
                    return true;
                }
                
            default:
                return false;
            }
        }
        
        return false;
    }
    
    static func executeRequest(route: String, method:HTTPMethod, params: Parameters, headers: HTTPHeaders = headers,success:@escaping (JSON) -> Void, error:@escaping (ApiError)->()){
        
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
                    
                case .failure( _):
                    print(String(data: response.data!, encoding: String.Encoding.utf8) as String!)
                    if(!genericHandleErrorCodes(code: response.response?.statusCode)){
                        //TxhjRU
                        guard let data = response.data else  { error(ApiError(string: "An unknown error occured")); return;  }
                        
                        var errorThrow = false;//stupid workaround var for the catch block
                        
                        do {
                            let json = try JSON(data: data)
                            if json != JSON.null {
                                error(ApiError(json: json));
                            }
                            else
                            {
                                error(ApiError(string: "An unknown error occured"));
                            }
                        }
                        catch {
                            errorThrow = true;
                        }
                        
                        if errorThrow {
                             error(ApiError(string: "An unknown error occured"));
                        }
                    
                    }
                }
            }
        
    }
    
    static func example(success:@escaping () -> Void, error:@escaping (ApiError)->()){
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

    static func JoinGroup(group_code: String,group_name: String, user_name: String, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        
        let customHeaders: HTTPHeaders = [
            "device-id" : Util.getDeviceId()
        ];
        
        executeRequest(
            route: "group/join",
            method: .post,
            params: [
                "group_name": group_name,
                "user_name": user_name,
                "group_code": group_code,
            ],
            headers: customHeaders,
            success: { json in
                let g = Group(name: json["name"].stringValue, code: json["code"].stringValue);
                guard let gs = g else { error(ApiError(string: "There was a problem joing the group.")); return; }
                if Group.writeToDisk(group: gs) {
                    _ = reloadHeaders();
                    success();
                }
                else {
                    error(ApiError(string: "There was a problem joing the group."))
                }
            },
                error: { err in
                    error(err);
            }
        );
    }
    
    static func GetUser(user_id: String, success:@escaping (User) -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "user/" + user_id,
            method: .get,
            params: [:],
            success: { json in
                let user = User(id: json["id"].intValue, name: json["name"].stringValue, group_code: "NULL")
                success(user);
            },
                error: { err in
                    error(err);
            }
        );
    }
    
    
    static func UpdateUser(name: String, success:@escaping (User) -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "user/",
            method: .put,
            params: [
                "name": name,
                ],
            success: { json in
                let user = User(id: json["id"].intValue, name: json["name"].stringValue, group_code: "NULL")
                success(user);
            },
            error: { err in
                error(err);
            }
        );
    }
    
    static func LeaveGroup(success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "group/leave",
            method: .delete,
            params: [:],
            success: { json in
                success();
            },
            error: { err in
                error(err);
            }
        );
    }

    static func GetBills(success:@escaping ([Bill]) -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "group/bills",
            method: .get,
            params: [:],
            success: { json in
                var bills: [Bill] = [];
                
                for (_, o) in json {
                    bills.append(Bill(owner_id: o["owner_id"].intValue, name: o["name"].stringValue, total: Decimal(o["total"].doubleValue), date_assigned: o["date_assigned"].stringValue, date_paid: o["date_paid"].stringValue, date_due: o["date_due"].stringValue))
                }
                
                success(bills);
        },
            error: { err in
                error(err);
        }
        );
    }
    
    static func CreateBill(bill: Bill, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd HH:mm:ss";
        
        executeRequest(
            route: "bill",
            method: .post,
            params: [
                "name": bill.name,
                "total": bill.total,
                "date_assigned": df.string(from: bill.date_assigned),
                //TODO: change date paid back
                "date_paid": df.string(from: Date()),
                //"date_paid": bill.date_paid == nil ? "" : df.string(from: bill.date_paid!),
                "date_due": df.string(from: bill.date_due),
                ],
            success: { json in
                success();
        },
            error: { err in
                error(err);
        }
        );
    }
    
}

