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
                //print(String(data: response.data!, encoding: String.Encoding.utf8) as String!)
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
    
    //MARK: ---------EXAMPLE---------
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

    //MARK: Group Functions
    
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
                "platform": "ios"
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
    
    static func editGroup(group: Group, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "group",
            method: .put,
            params: [
                "name": group.name,
            ],
            success: { json in
                success();
            },
            error: { err in
                error(err);
            }
        );
    }
    
    static func getGroup(success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "group",
            method: .get,
            params: [:],
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
    
    static func getGroupMembers(success:@escaping (_:[User]) -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "group/members",
            method: .get,
            params: [:],
            success: { json in
                var users: [User] = [];
                for (_, o) in json {
                    let user = User(id: o["id"].intValue, name: o["name"].stringValue, group_code: "")
                    users.append(user)
                }
                
                success(users);
            },
            error: { err in
                error(err);
            }
        );
    }
    
    //MARK: User Functions
    

    static func GetUser(user_id: String, success:@escaping (User) -> Void, error:@escaping (ApiError)->()) {
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
            route: "user",
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
    
    static func getDashboard(success:@escaping (_: Dashboard) -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "dashboard",
            method: .get,
            params: [:],
            success: { json in 
                
                let db = Dashboard(
                    mbc: json["myBillCount"].intValue,
                    mubc: json["myUnpaidBillCount"].intValue,
                    mbpc: json["myBillsPayerCount"].intValue,
                    mbpp: json["myBillsPayersPaid"].intValue,
                    mbppt: json["myBillsPayerPaidTotal"].doubleValue,
                    mbpptd: json["myBillsPayerPaidToDate"].doubleValue,
                    pt: json["payTotal"].doubleValue,
                    pttd: json["payTotalToDate"].doubleValue,
                    ptc: json["payTotalCount"].intValue,
                    ptctd: json["payTotalCountToDate"].intValue,
                    ndd: Util.formatDate(string: json["nextDueDate"].stringValue)
                )
                
                success(db);
            },
            error: { err in
                error(err);
            }
        );
    }
    
    static func registerPush(push_id: String, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "user/push",
            method: .post,
            params: [
                "push_id": push_id,
                ],
            success: { json in
                success();
        },
            error: { err in
                error(err);
        }
        );
    }

    static func unregisterPush(success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "user/push",
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
    
    //MARK: Bill Functions
    
    static func GetBills(archived: Bool = false, success:@escaping ([Bill]) -> Void, error:@escaping (ApiError)->()){
        var route: String = "group/bills";
        if archived {
            route = "group/archive";
        }
        executeRequest(
            route: route,
            method: .get,
            params: [:],
            success: { json in
                var bills: [Bill] = [];
                
                for (_, o) in json {
                    let bill = Bill(id: o["id"].intValue,owner_id: o["owner_id"].intValue, name: o["name"].stringValue, total: o["total"].doubleValue, date_assigned: o["date_assigned"].stringValue, date_paid: o["date_paid"].stringValue, date_due: o["date_due"].stringValue, is_archive: o["archived"].boolValue)
                    bill.subtotal = Double(o["subtotal"].doubleValue)
                    bill.split_cost = Double(o["split_cost"].doubleValue)

                    for (_, u) in o["payers"] {
                        let user = User(id: u["id"].intValue, name: u["name"].stringValue, group_code: "")
                        bill.payers.append(UserPaid(user: user,paid:u["pivot"]["has_paid"].boolValue))
                    }
                    bills.append(bill)
                }
                bills = bills.sorted(by: {a,b in return a.date_assigned < b.date_assigned})
                success(bills);
            },
            error: { err in
                error(err);
            }
        );
    }
    
    static func CreateBill(bill: Bill, success:@escaping (_ :Bill) -> Void, error:@escaping (ApiError)->()){
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd HH:mm:ss";
        
        executeRequest(
            route: "bill",
            method: .post,
            params: [
                "name": bill.name,
                "total": bill.total,
                "date_assigned": df.string(from: bill.date_assigned),
                "date_paid": bill.date_paid == nil ? "" : df.string(from: bill.date_paid!),
                "date_due": df.string(from: bill.date_due),
                ],
            success: { o in // o is json
                let bill = Bill(id: o["id"].intValue,owner_id: o["owner_id"].intValue, name: o["name"].stringValue, total: o["total"].doubleValue, date_assigned: o["date_assigned"].stringValue, date_paid: o["date_paid"].stringValue, date_due: o["date_due"].stringValue, is_archive: o["archived"].boolValue)
                bill.subtotal = Double(o["subtotal"].doubleValue)
                bill.split_cost = Double(o["split_cost"].doubleValue)
                success(bill);
            },
            error: { err in
                error(err);
            }
        );
    }

    static func getBillDetail(bill_id: Int, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "bill/" + String(bill_id),
            method: .get,
            params: [:],
            success: { json in
                success();
            },
            error: { err in
                error(err);
            }
        );
    }
    
    static func updateBill(bill: Bill, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd HH:mm:ss";
        
        executeRequest(
            route: "bill/" + String(bill.id),
            method: .put,
            params: [
                "name": bill.name,
                "total": bill.total,
                "date_assigned": df.string(from: bill.date_assigned),
                "date_paid": bill.date_paid == nil ? "" : df.string(from: bill.date_paid!),
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
    
    static func deleteBill(bill: Bill, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "bill/" + String(bill.id),
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
    
    static func addPayers(bill: Bill, users: [User], success:@escaping (_: User) -> Void, error:@escaping (ApiError)->()){
        for user in users {
            executeRequest(
                route: "bill/" + String(bill.id) + "/payer/" + String(user.id),
                method: .post,
                params: [:],
                success: { json in
                    
                    success(user);
                },
                error: { err in
                    print(bill.id, bill.owner_id, user.id)
                    error(err);
                }
            );
        }
    }
    
    static func deletePayers(bill: Bill, users: [User], success:@escaping () -> Void, error:@escaping (ApiError)->()){
        
        for user in users {
            executeRequest(
                route: "bill/" + String(bill.id) + "/payer/" + String(user.id),
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
    }
    
    static func markPayerPaid(bill: Bill, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "bill/" + String(bill.id) + "/payer/pay",
            method: .put,
            params: [:],
            success: { json in
                success();
        },
            error: { err in
                error(err);
        }
        );
    }
    
    static func archiveBills(bills: [Bill], success:@escaping () -> Void, error:@escaping (String)->()){
        let queue = DispatchGroup();
          var errors: [ApiError] = [];
        
        for bill in bills {
            var payerUnpaidCount = 0;
            if bill.date_paid == nil { continue; }
            bill.payers.forEach({if $0.paid == false { payerUnpaidCount += 1}})
            if payerUnpaidCount != 0 { continue; }
            	
            queue.enter()
            executeRequest(
                route: "bill/" + String(bill.id) + "/archive",
                method: .put,
                params: [:],
                success: { json in
                    queue.leave();
                },
                error: { err in
                    queue.leave();
                    errors.append(err);
                }
            );
        }
        
        queue.notify(queue: .main) {
            if errors.count == 0 {
                success();
            }else {
                var str = "";
                for err in errors {
                    str += err.toString() + "\n";
                }
                error(str);
            }
        }
        
    }
    
    static func duplicateBills(bills: [Bill], success:@escaping () -> Void, error:@escaping (String)->()){
        let queue = DispatchGroup();
        var errors: [ApiError] = [];
        
        for bill in bills {
            queue.enter();
            executeRequest(
                route: "bill/" + String(bill.id) + "/duplicate",
                method: .post,
                params: [:],
                success: { json in
                    queue.leave();
                },
                error: { err in
                    queue.leave();
                    errors.append(err);
                }
            );
        }
        
        queue.notify(queue: .main) {
            if errors.count == 0 {
                success();
            }else {
                var str = "";
                for err in errors {
                    str += err.toString() + "\n";
                }
                error(str);
            }
        }
    }
    
    static func notifyUnpaidPayers(bill: Bill, success:@escaping () -> Void, error:@escaping (ApiError)->()){
        executeRequest(
            route: "bill/" + String(bill.id) + "/notify",
            method: .post,
            params: [:],
            success: { json in
                success();
        },
            error: { err in
                error(err);
        }
        );
    }

}

