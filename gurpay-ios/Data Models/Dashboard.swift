//
//  Dashboard.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 5/16/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import Foundation

class Dashboard {
    
    //MARK: Properties
    
    var myBillCount: Int
    var myUnpaidBillCount: Int
    
    var myBillsPayerCount: Int
    var myBillsPayersPaid: Int
    
    var myBillsPayerPaidTotal: Double
    var myBillsPayerPaidToDate: Double
    
    var payTotal: Double
    var payTotalToDate: Double
    
    var payTotalCount: Int
    var payTotalCountToDate: Int
    
    var nextDueDate: Date?
    
    
    init(mbc: Int, mubc: Int, mbpc: Int, mbpp: Int, mbppt: Double, mbpptd: Double, pt: Double, pttd: Double, ptc: Int, ptctd: Int, ndd: Date?) {
        self.myBillCount = mbc
        self.myUnpaidBillCount = mubc
        
        self.myBillsPayerCount = mbpc
        self.myBillsPayersPaid = mbpp
        
        self.myBillsPayerPaidTotal = mbppt
        self.myBillsPayerPaidToDate = mbpptd
        
        self.payTotal = pt
        self.payTotalToDate = pttd
        
        self.payTotalCount = ptc
        self.payTotalCountToDate = ptctd
        
        self.nextDueDate = ndd
    }
    
    func bulkLabel()->[String] {
        var str: [String] = [];
        
        str.append("You have paid \(myUnpaidBillCount)/\(myBillCount) bills.\n")
        str.append("\(myBillsPayersPaid)/\(myBillsPayerCount) people have paid you.\n")
        str.append("You have recieved \(myBillsPayerPaidToDate)/\(myBillsPayerPaidTotal) dollars.\n")
        str.append("You have paid \(payTotalCountToDate)/\(payTotalCount) bills so far.\n")
        str.append("You have paid \(payTotalToDate)/\(payTotal) so far.\n")
        str.append("Your next bill is due on \(Util.displayDate(date: nextDueDate)!).\n")
        
        return str;
    }
    
}
